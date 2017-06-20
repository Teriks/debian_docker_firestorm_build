import pake
import os
import getpass
import shutil
from pake import process

pk = pake.init()


IMAGE_NAME = pk.get_define('IMAGE', 'firestorm_build_env_ubuntu_16.04')

IMAGE_VERSION = pk.get_define('IMAGE_VERSION', '0.2.2')

WIN_VOLUME = pk.get_define('WIN_VOLUME', 'firestorm_build_env_volume')

ENTRY_SCRIPT = 'src/entry.sh'

IMAGE = '{}:{}'.format(IMAGE_NAME, IMAGE_VERSION)


import subprocess

def on_windows():
    return os.name == 'nt'


def docker_image_exists(name):
    code = process.call('docker', 'image', 'inspect', name, 
                        stdout=process.DEVNULL, 
                        stderr=process.DEVNULL)
    return code == 0


def docker_volume_exists(name):
    code = process.call('docker', 'volume', 'inspect', name, 
                        stdout=process.DEVNULL, 
                        stderr=process.DEVNULL)
    return code == 0
    
    
def get_windows_interactive_switch(have_winpty):
    have_uname = shutil.which('uname') != None
    
    if have_uname:
        uname = process.check_output('uname', '-s').decode()
        if uname.startswith('MINGW64') or uname.startswith('CYGWIN'):
            return '-ti' if have_winpty else '-i'

    return '-ti'
          
    
def run_docker(enter_to_shell):
    interactive_message = 'true' if enter_to_shell else 'false'
    

    have_winpty = shutil.which('winpty') != None
    
    pwd = os.getcwd()
    
    path_escape = ''
    
    if have_winpty:
        pwd = '/'+pwd
        path_escape = '/'
    
    if on_windows():
        args = []
        
        if have_winpty:
            args += ['winpty']
    
        args += [
            'docker', 'run', get_windows_interactive_switch(have_winpty),
            '-e', 'ON_WINDOWS=true',
            '-e', 'INTERACTIVE_MESSAGE=' + interactive_message,
            '-v', '{volume}:{path_escape}/home/build'.format(volume=WIN_VOLUME, path_escape=path_escape),
            '-v', '{pwd}\\src:{path_escape}/home/build/src'.format(pwd=pwd, path_escape=path_escape),
            '-v', '{pwd}\\artifacts:{path_escape}/home/build/artifacts'.format(pwd=pwd, path_escape=path_escape),
            '-v', '{pwd}\\config:{path_escape}/home/build/config'.format(pwd=pwd, path_escape=path_escape),
            IMAGE, ENTRY_SCRIPT
            ]
    else:
    
        username = getpass.getuser()
        args = [
            'docker', 'run', '-ti',
            '-e', 'ON_WINDOWS=false',
            '-e', 'INTERACTIVE_MESSAGE=' + interactive_message,
            '-e', 'LOCAL_USER_ID=' + str(os.getuid()),
            '-e', 'LOCAL_USER=' + getpass.getuser(),
            '-v', '{pwd}/install.cache:/var/tmp/{username}/install.cache'.format(pwd=pwd, username=username),
            '-v', '{pwd}:/home/build'.format(pwd=pwd),
            IMAGE, ENTRY_SCRIPT
            ]
            

    if not enter_to_shell:
        args += ['{path_escape}/home/build/src/build_in_docker.sh'.format(path_escape=path_escape)]

    process.call(args)
    

@pk.task(no_header=True)
def build_image(ctx):
    if not docker_image_exists(IMAGE):
        ctx.call('docker', 'build', '--tag', IMAGE, 'src')


@pk.task(build_image, no_header=True)
def create_volume(ctx):
    if on_windows():
        if not docker_volume_exists(WIN_VOLUME):
            ctx.call('docker', 'volume', 'create', WIN_VOLUME)    
        

@pk.task(create_volume, no_header=True)
def shell(ctx):
    """Run an interactive shell inside the container."""
    
    if on_windows():
        pake.FileHelper().makedirs('artifacts')
    
    run_docker(enter_to_shell=True)
    
    
@pk.task(create_volume, no_header=True)
def build(ctx):
    """Build Firestorm Viewer inside the container."""

    if on_windows():
        pake.FileHelper().makedirs('artifacts')
    
    run_docker(enter_to_shell=False)
  
 
pake.run(pk, tasks=build)