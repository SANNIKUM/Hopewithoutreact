# Set the working application directory
# # working_directory "/path/to/your/app"
working_directory "/var/lib/go-agent/pipelines/rails_backend"
#
# # Unicorn PID file location
# # pid "/path/to/pids/unicorn.pid"
pid "/tmp/unicorn.pid"
#
# # Path to logs
# # stderr_path "/path/to/log/unicorn.log"
# # stdout_path "/path/to/log/unicorn.log"
stderr_path "/tmp/unicorn.log"
stdout_path "/tmp/unicorn.log"
#
# # Unicorn socket
listen "/tmp/unicorn.hope.sock"
#
# # Number of processes
# # worker_processes 4
worker_processes 50
#
# # Time-out
# timeout 30
#
#timer_resolution 500ms;
#worker_rlimit_nofile 10240;
