# First steps
1. Installed Termux from F-Froid
2. pkg install git
3. mkdir ~/main/docs
4. used nano Termux.evolving
5. mkdir scripts for maintenance
6. created cleanup.sh to update and remove umused packages
7. make it executable with the following command "chmod +x ~/main/scripts/cleanup.sh"
8. nano .basrc to add to PATH
9. Install SSH (Optional): If you plan to use SSH for GitHub, install SSH as well:
    pkg install openssh
10. Set Up Storage: Allow Termux to access your device's storage:

    termux-setup-storage

11. Configure Git: Set your username and email for Git commits:

    git config --global user.name "istinic"
    git config --global user.email "claudiunaghi@outlook.com"

12. Generate SSH Key (if using SSH):

    ssh-keygen -t rsa -C "claudiunaghi@outlook.com"
SHA256:4GegugUTaUHLiZ9XA5Pj5jeo3hOaucl6B5+ljc9eZNA claudiunaghi@outlook.com

13. Authenticate with GitHub: Log into your GitHub account using SSH:

    ssh -T git@github.com
SHA256:+DiY3wvvV6TuJJhbpZisF/zLDA0zPMSvHdkr4UvCOqU.





