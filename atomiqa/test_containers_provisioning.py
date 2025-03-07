import docker
from testcontainers.core.container import DockerContainer
from testcontainers.core.waiting_utils import wait_for_logs
import time
import uuid
import os
import io
import tarfile
import json
import threading
import argparse
import logging


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class FullStackServiceBundle:

    def __init__(self):
        self.client = docker.from_env()
        self.network_name = f"network_{uuid.uuid4()}"
        self.network = self.client.networks.create(self.network_name, driver="bridge")
        self.containers = []

    def start_services(self, combinations):
        try:
            # Load the browser combinations from JSON file
            # directory = 'test_containers'
            # file_path = os.path.join(directory, 'corporate_combinations.json')
            # with open(file_path, 'r') as f:
            #     combinations = json.load(f)
            list_containers_with_size()
            # Start Redis container
            self.redis_container = DockerContainer("redis:7.2-alpine") \
                .with_command("redis-server --appendonly yes") \
                .with_bind_ports(6379, 6379) \
                .with_network(self.network)
            self.redis_container.start()
            self.containers.append(self.redis_container._container)  # Track for cleanup
            wait_for_logs(self.redis_container, r"Ready to accept connections")

            list_containers_with_size()
            # Start PostgreSQL container
            self.postgres_container = DockerContainer("postgres:16.1-alpine") \
                .with_bind_ports(5432, 5432) \
                .with_name("tj_qa-db") \
                .with_env("POSTGRES_DB", "corporate_backend") \
                .with_env("POSTGRES_USER", "postgres") \
                .with_env("POSTGRES_PASSWORD", "postgres") \
                .with_network(self.network)
            self.postgres_container.start()
            self.containers.append(self.postgres_container._container)  # Track for cleanup
            wait_for_logs(self.postgres_container, r"database system is ready to accept connections")
            time.sleep(7)
            
            list_containers_with_size()
            # Access the underlying PostgreSQL container using Docker SDK
            postgres_container_obj = self.client.containers.get(self.postgres_container._container.short_id)
            # Copy the dump files to the PostgreSQL container
            dump_file_path = os.path.join(os.path.dirname(__file__), 'Corporate_QA_schemas.sql')
            self.copy_file_to_container(dump_file_path, '/tmp/Corporate_QA_schemas.sql', postgres_container_obj)
            dump_file_path = os.path.join(os.path.dirname(__file__), 'Corporate_QA_data.sql')
            self.copy_file_to_container(dump_file_path, '/tmp/Corporate_QA_data.sql', postgres_container_obj)

            list_containers_with_size()
            # Restore the database dump
            restore_command = "pg_restore --verbose --no-acl --no-owner -h localhost -U postgres -d corporate_backend /tmp/Corporate_QA_schemas.sql"
            result_restore = postgres_container_obj.exec_run(['sh', '-c', restore_command])
            if result_restore.exit_code == 0:
                print("Schema restored successfully.")
            else:
                print(f"Schema restoration failed: {result_restore.output.decode()}")

            restore_command = "pg_restore --verbose --no-acl --no-owner -h localhost -U postgres -d corporate_backend /tmp/Corporate_QA_data.sql"
            result_restore = postgres_container_obj.exec_run(['sh', '-c', restore_command])
            if result_restore.exit_code == 0:
                print("Data restored successfully.")
            else:
                print(f"Data restoration failed: {result_restore.output.decode()}")

            list_containers_with_size()
            # Start frontend container
            self.frontend_container = DockerContainer("corporate-local-frontend") \
                .with_name("frontend") \
                .with_network(self.network)
            self.frontend_container.start()
            self.containers.append(self.frontend_container._container)

            list_containers_with_size()
            # Start backend container
            self.backend_container = DockerContainer("corporate-local-backend") \
                .with_name("backend") \
                .with_env("DB_HOST", "tj_qa-db") \
                .with_env("DB_USERNAME", "postgres") \
                .with_env("DB_PASSWORD", "postgres") \
                .with_env("DB_DATABASE", "corporate_backend") \
                .with_command("pnpm start") \
                .with_network(self.network)
            self.backend_container.start()
            time.sleep(40)
            self.containers.append(self.backend_container._container)

            list_containers_with_size()
            self.nginx_container = DockerContainer("nginx:1.25.3") \
            .with_name("nginx") \
            .with_bind_ports(80, 80) \
            .with_volume_mapping(os.path.join(os.path.dirname(__file__), 'nginx.conf'), '/etc/nginx/conf.d/default.conf') \
            .with_network(self.network) 
            self.nginx_container.start()
            self.containers.append(self.nginx_container._container)
            print("Nginx container started successfully.")
            time.sleep(10)
            
            list_containers_with_size()
            # Local path for saving reports
            # local_report_dir = os.path.abspath("test_containers")  # Use absolute path

            # Iterate through each browser in the JSON and create separate QA containers
            qa_containers = []
            index = 1
            for combination in combinations:
                list_containers_with_size()
                browser = combination["browser"]
                execution_module = combination["executionModule"]
                parallel_threads = combination["parallelThreads"]
                send_email = combination["sendEmail"]
                # Create a unique directory for each browser's report
                browser_report_dir = os.path.abspath(os.path.join("reports", f"reports_{browser}_{index}"))
                os.makedirs(browser_report_dir, exist_ok=True)

                qa_container = DockerContainer(f"qa_automation_{index}:latest") \
                    .with_name(f"qa_container_tj_{browser}_{index}") \
                    .with_network(self.network) \
                    .with_command("sleep infinity") \
                    .with_volume_mapping(browser_report_dir, "/robot/reports",  mode='rw')   # Normalize path
                qa_container.start()
                self.containers.append(qa_container._container)  # Track for cleanup
                qa_containers.append((qa_container, browser, execution_module, parallel_threads))
                index += 1

            # Function to run robot command in the container
            def run_robot_command(qa_container_obj, browser, execution_module, parallel_threads):
                robot_command = (
                f"pabot --testlevelsplit --processes {parallel_threads} --outputdir /robot/reports "
                f"-v browser:{browser} "
                f"-v environment:QA "
                f"/robot/SuperAdmin/TestCases/{execution_module}/"  # Ensure this path is correct in the container
                )
                exec_result = qa_container_obj.exec_run(['sh', '-c', robot_command], stream=True)

                logger.info(f"QA container ({browser}) test execution started.")
                # print(f"QA container ({browser}) test execution output:")
                # print(result.output.decode())
                #Get logs separately for stdout and stderr

                for log in exec_result.output:
                    decoded_log = log.decode('utf-8')
                    logger.info(decoded_log)
                    print(decoded_log)
                stdout_logs = qa_container_obj.logs(stdout=True, stderr=False)
                stderr_logs = qa_container_obj.logs(stdout=False, stderr=True)
                # print(f"QA container ({browser}) stdout logs:")
                # if stdout_logs:
                #     print(stdout_logs.decode('utf-8'))
                # if stderr_logs:
                #     print(f"QA container ({browser}) stderr logs:")
                #     print(stderr_logs.decode('utf-8'))
                # print(f"QA container ({browser}) test execution output: {result.output.decode()}")

                # if stdout_logs:
                #     stdout_decoded = stdout_logs.decode('utf-8')
                #     # log_stream.put(f"QA container ({browser}) stdout logs:\n{stdout_decoded}")
                #     logger.info(f"QA container ({browser}) stdout logs:\n{stdout_decoded}")
                #     print(stdout_decoded)

                # if stderr_logs:
                #     stderr_decoded = stderr_logs.decode('utf-8')
                #     # log_stream.put(f"QA container ({browser}) stderr logs:\n{stderr_decoded}")
                #     logger.info(f"QA container ({browser}) stderr logs:\n{stderr_decoded}")
                #     print(stderr_decoded)

                logger.info(f"QA container ({browser}) test execution finished.")

            

            # Run containers in parallel using threads
            threads = []
            for qa_container, browser, execution_module, parallel_threads in qa_containers:
                qa_container_obj = self.client.containers.get(qa_container._container.short_id)
                thread = threading.Thread(target=run_robot_command, args=(qa_container_obj, browser, execution_module, parallel_threads))
                thread.start()
                threads.append(thread)

            # Wait for all threads to complete
            for thread in threads:
                thread.join()

            time.sleep(5)
        finally:
            # Stop and remove all containers, then remove the network
            for container in self.containers:
                list_containers_with_size()
                try:
                    container.stop()
                    container.remove()
                except Exception as e:
                    logger.info(f"Error stopping/removing container: {e}")
            # Now remove the network
            try:
                self.client.networks.get(self.network_name).remove()
                logger.info(f"Network {self.network_name} removed successfully.")
                list_containers_with_size()
                logger.info("All Testcontainers are stopped")
                logger.info("--------------------------------------------------------------------------------")
            except Exception as e:
                print(f"Error while removing network: {e}")

    def copy_file_to_container(self, src, dst, container):
        with open(src, 'rb') as f:
            data = io.BytesIO()
            with tarfile.open(fileobj=data, mode='w') as tar:
                tarinfo = tarfile.TarInfo(name=os.path.basename(src))
                tarinfo.size = f.seek(0, io.SEEK_END)
                f.seek(0)
                tar.addfile(tarinfo, f)
            data.seek(0)
            container.put_archive(path='/tmp', data=data)

def start_container_deploy(combinations):
    directory = 'test_containers'
    file_path = os.path.join(directory, 'corporate_combinations.json')
    with open(file_path, 'w') as file:
        json.dump(combinations, file, indent=4)

    full_stack_service = FullStackServiceBundle()
    full_stack_service.start_services()
    
def list_containers_with_size():
    # Create a Docker client
    client = docker.from_env()

    # List all containers (running and stopped)
    containers = client.containers.list(all=True)

    # Header like docker container ls command
    header = "{:<12} {:<30} {:<10} {:<15} {:<15} {:<15}".format(
        "CONTAINER ID", "IMAGE", "COMMAND", "STATUS", "PORTS", "SIZE"
    )
    logger.info(header)
    logger.info('-' * len(header))

    # Print container details with size
    for container in containers:
        container_info = client.api.inspect_container(container.id)
        container_size_rw = container_info.get('SizeRw', 0)  # Writable layer size
        container_size_rootfs = container_info.get('SizeRootFs', 0)  # Entire container size

        # Format size as in docker command
        total_size_mb = (container_size_rw + container_size_rootfs) / (1024 * 1024)
        size_str = f"{total_size_mb:.2f} MB"

        # Get ports info
        ports = container_info.get('NetworkSettings', {}).get('Ports', {})
        ports_str = ", ".join([f"{k} -> {v[0]['HostPort']}" if v else k for k, v in ports.items()]) or "-"

        # Format container details
        container_details = "{:<12} {:<30} {:<10} {:<15} {:<15} {:<15}".format(
            container.id[:12],                  # Truncated container ID
            container.image.tags[0] if container.image.tags else "<none>",
            container_info['Config']['Cmd'][0] if container_info['Config']['Cmd'] else "<none>",
            container.status.capitalize(),
            ports_str,
            size_str
        )
        logger.info(container_details)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Start test containers with arguments.")
    parser.add_argument('--arg1', type=str, required=True, help='combinations as argument')
    args = parser.parse_args()
    combinations = json.loads(args.arg1)
    print("------------------------------------------------------")
    print(combinations)
    # directory = 'app/test_containers'
    
    # file_path = os.path.join(directory,'corporate_combinations.json')

    # with open(file_path, 'w') as file:
    #     json.dump(combinations, file, indent=4)
    full_stack_service = FullStackServiceBundle()
    full_stack_service.start_services(combinations)
