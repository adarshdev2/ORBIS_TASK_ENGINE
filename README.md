🚀 Orbis Task Engine (OTE)

A lightweight, modular CLI-based system automation tool designed for efficient system administration and monitoring in Linux environments.

📌 Overview

Orbis Task Engine (OTE) automates essential system administration tasks such as monitoring, logging, scheduling, and maintenance. Built using Bash scripting and SQLite, it provides a centralized and structured way to manage system operations.

✨ Features
🔍 Disk usage analysis
📂 Automatic file organization
📊 Real-time system monitoring (CPU, Memory, Disk, Network)
⚙️ Task and process management
🧹 System cleaning (cache, temp, trash)
⏱️ Scheduled task automation using cron
🌐 Network usage tracking
📈 Application usage monitoring
🗂️ Centralized logging with SQLite
📜 Log viewing and filtering

Orbis-Task-Engine/
│── main.sh
│── utils.sh
│── modules/
│   ├── disk_analyzer.sh
│   ├── file_organizer.sh
│   ├── resource_monitor.sh
│   ├── task_manager.sh
│   ├── system_cleaner.sh
│   ├── boot_time_logger.sh
│   ├── scheduled_task_runner.sh
│   ├── network_usage_viewer.sh
│   ├── app_usage_tracker.sh
│   └── log_viewer.sh
│── db/
│   └── orbis_engine.db
│── config/
│   └── config.cfg

⚙️ Tech Stack
Language: Bash Scripting
Database: SQLite3
OS: BOSS GNU/Linux / Arch Linux
Tools: Cron, Terminal (GNOME/Konsole), Vim/Nano

💻 System Requirements
Hardware
Processor: 2.0 GHz or above
RAM: Minimum 2 GB (Recommended 4 GB)
Storage: 20 GB free space
Software
Linux OS
Bash Shell
SQLite3
Cron Scheduler

# Clone the repository
git clone https://github.com/your-username/orbis-task-engine.git

# Navigate to project directory
cd orbis-task-engine

# Give execute permission
chmod +x main.sh

# Run the application
./main.sh

🧠 How It Works
The system is menu-driven (CLI-based)
Each module performs a specific task
Logs are stored in an SQLite database
Automation is handled using cron jobs
Real-time system data is collected and processed

📊 Modules
Main Menu Controller
Disk Analyzer
File Organizer
Resource Monitor
Task Manager
System Cleaner
Boot Time Logger
Scheduled Task Runner
Network Usage Viewer
App Usage Tracker
Log Viewer

🧪 Testing
✅ Unit Testing (module-wise)
✅ Integration Testing (module interaction)
✅ Validation Testing (real-time scenarios)

📈 Advantages
Reduces manual system administration effort
Centralized logging system
Improves performance monitoring
Automated task scheduling
Lightweight and efficient

🔮 Future Enhancements
GUI-based interface
Web-based remote monitoring
Role-based authentication system
Cloud integration
AI-based predictive analysis
Advanced log analytics dashboards

📌 Conclusion
Orbis Task Engine simplifies Linux system management by automating repetitive tasks and providing structured monitoring and logging. It is efficient, scalable, and ideal for low-resource environments.

👨‍💻 Author

Adarsh P
MSc Computer Science
