
from flask import Blueprint, request, jsonify, Response, stream_with_context, g, send_from_directory
from flask_jwt_extended import create_access_token, jwt_required, get_jwt
from werkzeug.security import generate_password_hash, check_password_hash
from .models import User, db, UserStatus, UserRole, AuditLog, TokenBlacklist, ProjectConfiguration,Execution,RuntimeLogs,ReportLogs, QAGitCredential, QADevCredentialFE, QADevCredentialBE, HostedEnvironment, Cloud, DBSchema, DBDump, Secrets, AIO, ModuleTag
from .decorators import admin_required
from .ec2_operations import log_stream, mobile_logger, mobile_log_stream, execute_ssh_command, logger, generate_dockerfile_web_ec2, create_or_update_file_on_ec2, build_docker_image_on_ec2, remove_existing_image, download_ec2_files, execute_mobile_ssh_command, update_web_environment_combinations_ec2


main = Blueprint('main', __name__)


@main.route('/android-lamdatest-ec2', methods=['POST'])
# @jwt_required()
def save_android_combinations():
    data = request.get_json()
    
    # Check if JSON data is present
    if data is None:
        return jsonify({"error": "No JSON data provided"}), 400

    # Extract the clone path
    clone_path = data.get('clone_path')
    
    # Validate the clone path
    if clone_path is None:
        return jsonify({"error": "Clone path is not set"}), 400

    clone_path = clone_path.replace("\\", "/")
    
    android_combinations = data.get('android_combinations')  # Get JSON data from the request
    if not android_combinations:
        return jsonify({"error": "No JSON data provided"}), 400

    try:
        command = (
                f"source test_clone_path/myenv/bin/activate && "
                f"cd {clone_path} && "
                f"pip install -r requirements.txt "
            )
        execute_mobile_ssh_command(command)
        # Iterate through combinations and run the command on EC2
        for combination in android_combinations:
            device = combination.get('device')
            os_version = combination.get('osversion')
            mobile_logger.info(f"Selected Device: {device} with OS version: {os_version}")
            mobile_logger.info(f"Connecting With Lamdatest Server")
            mobile_logger.info(f"Executing Tests on Device: {device} with OS version: {os_version}")
            # Command to create a virtual environment and install dependencies
            command = (
                f"source test_clone_path/myenv/bin/activate && "
                f"cd {clone_path} && "
                f"robot -i demo "
                f"--outputdir reports/\"{device}\"_\"{os_version}\" "
                f"--variable deviceName:\"{device}\" "
                f"--variable platformVersion:\"{os_version}\" "
                f"--variable lt_host:\"{current_app.config['LT_HOST']}\" "
                f"TestCases/my_account_tests.robot"
            )
            print(command)
            # Execute command on EC2
            execute_mobile_ssh_command(command)  # Output will be logged in real-time
        report_folder = f'{clone_path}/reports'
        download_ec2_files(report_folder)
        return jsonify({"message": "Test executed successfully"}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

@main.route('/ios-lamdatest-ec2', methods=['POST'])
# @jwt_required()
def save_ios_combinations():
    data = request.get_json()
    
    # Check if JSON data is present
    if data is None:
        return jsonify({"error": "No JSON data provided"}), 400

    # Extract the clone path
    clone_path = data.get('clone_path')
    
    # Validate the clone path
    if clone_path is None:
        return jsonify({"error": "Clone path is not set"}), 400

    clone_path = clone_path.replace("\\", "/")

    ios_combinations = data.get('ios_combinations')  # Get JSON data from the request
    if not ios_combinations:
        return jsonify({"error": "No JSON data provided"}), 400

    try:
        command = (
                f"source test_clone_path/myenv/bin/activate && "
                f"cd {clone_path} && "
                f"pip install -r requirements.txt "
            )
        execute_mobile_ssh_command(command)
        # Iterate through combinations and run the command on EC2
        for combination in ios_combinations:
            device = combination.get('device')
            os_version = combination.get('osversion')
            mobile_logger.info(f"Selected Device: {device} with OS version: {os_version}")
            mobile_logger.info(f"Connecting With Lamdatest Server")
            mobile_logger.info(f"Executing Tests on Device: {device} with OS version: {os_version}")
            # Command to create a virtual environment and install dependencies
            command = (
                f"source test_clone_path/myenv/bin/activate && "
                f"cd {clone_path} && "
                f"robot -i demo "
                f"--outputdir reports/\"{device}\"_\"{os_version}\" "
                f"--variable deviceName:\"{device}\" "
                f"--variable platformVersion:\"{os_version}\" "
                f"--variable lt_host:\"{current_app.config['LT_HOST']}\" "
                f"IOS/TestCases/my_account_test.robot"
            )
            print(command)
            # Execute command on EC2
            execute_mobile_ssh_command(command)  # Output will be logged in real-time
        report_folder = f'{clone_path}/reports'
        download_ec2_files(report_folder)
        return jsonify({"message": "Test executed successfully"}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500
