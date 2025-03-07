from setuptools import setup, find_packages

setup(
    name='selfhealing',
    version='0.1.0',
    description='A self-healing module for automated UI tests using Robot Framework and Selenium.',
    author='Your Name',
    author_email='your.email@example.com',
    packages=find_packages(),
    install_requires=[
        'robotframework',
        'selenium',
        'openai',
        'rapidfuzz',
        'beautifulsoup4',
        'lxml',
        'python-dotenv'
    ],
    include_package_data=True,
    package_data={
        '': ['*.json', '*.env'],
    },
    entry_points={
        'console_scripts': [
            'selfhealing=selfhealing.main:main',  # Adjust this to your main entry point
        ],
    },
) 