import pake
import os
import getpass

import shutil

# We need .call for interactive output
# pake normally queues output to the task until it is done.
# subprocess.call is fine to use with pake as long as the build is not multithreaded, or is completely serial.
import subprocess

pk = pake.init()


IMAGE_NAME = pk.get_define('IMAGE', 'firestorm_build_env_ubuntu_16.04')

IMAGE_VERSION = pk.get_define('IMAGE_VERSION', '0.2.2')

WIN_VOLUME = pk.get_define('WIN_VOLUME', 'firestorm_build_env_volume')

ENTRY_SCRIPT = 'src/entry.sh'

IMAGE = '{}:{}'.format(IMAGE_NAME, IMAGE_VERSION)


def on_windows():
    return os.name == 'nt'


def docker_image_exists(ctx, name):
    return ctx.check_call('docker', 'image', 'inpect', name, ignore_errors=True) != 0


def docker_volume_exists(ctx, name):
    return ctx.check_call('docker', 'volume', 'inpect', name, ignore_errors=True) != 0
    
    
def get_windows_interactive_switch(have_winpty):
    have_uname = shutil.which('uname') != None
    
    if have_uname:
        uname = subprocess.check_output(['uname', '-s']).decode()
        if uname.startswith('MINGW64') or uname.startswith('CYGWIN'):
            return '-ti' if have_winpty else '-i'

    return '-ti'
          
    
def run_docker(enter_to_shell):
    enter_to_shell = 'true' if enter_to_shell else 'false'
    

    have_winpty = shutil.which('winpty') != None
    
    pwd = os.getcwd()
    
    sl = ''
    
    if have_winpty:
        pwd = '/'+pwd
        sl = '/'
    
    if on_windows():
        args = []
        
        if have_winpty:
            args += ['winpty']
    
        args += [
            'docker', 'run', get_windows_interactive_switch(have_winpty),
            '-e', 'ON_WINDOWS=true',
            '-e', 'INTERACTIVE_MESSAGE='+enter_to_shell,
            '-v', '{volume}:{sl}/home/build'.format(volume=WIN_VOLUME, sl=sl),
            '-v', '{pwd}\\src:{sl}/home/build/src'.format(pwd=pwd, sl=sl),
            '-v', '{pwd}\\artifacts:{sl}/home/build/artifacts'.format(pwd=pwd, sl=sl),
            '-v', '{pwd}\\config:{sl}/home/build/config'.format(pwd=pwd, sl=sl),
            IMAGE, ENTRY_SCRIPT
            ]
    else:
    
        username = getpass.getuser()
        args = [
            'docker', 'run', '-ti',
            '-e', 'ON_WINDOWS=false',
            '-e', 'INTERACTIVE_MESSAGE=' + enter_to_shell,
            '-e', 'LOCAL_USER_ID=' + str(os.getuid()),
            '-e', 'LOCAL_USER=' + getpass.getuser(),
            '-v', pwd+'/install.cache:/var/tmp/{}/install.cache'.format(username),
            '-v', pwd+':/home/build',
            IMAGE, ENTRY_SCRIPT
            ]
            

    if not enter_to_shell:
        args += ['/home/build/src/build_in_docker.sh']

    subprocess.call(args)
    

@pk.task(no_header=True)
def build_image(ctx):
    if not docker_image_exists(ctx, IMAGE):
        subprocess.call(['docker', 'build', '--tag', IMAGE])


@pk.task(build_image, no_header=True)
def create_volume(ctx):
    if on_windows():
        if not docker_volume_exists(ctx, WIN_VOLUME):
            subprocess.call(['docker', 'volume', 'create'])    
        

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