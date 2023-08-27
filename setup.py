from setuptools import setup, find_packages

setup(
    name='sbmp4a',
    version='VERSION',
    packages=[
        'sbmp4a',
        'sbmp4a.autoprocess',
        'sbmp4a.config',
        'sbmp4a.converter',
        'sbmp4a.resources',
    ],
    package_dir={
        'sbmp4a': '.',
    },
    entry_points={
        'console_scripts': [
            'sbmp4a=sbmp4a.manual:main',
        ],
    },
)