{
    "setupOptions": {
        "installPHP": {
            "versions": {
                "7.4.33": {
                    "x64": "https://windows.php.net/downloads/releases/php-7.4.33-Win32-vc15-x64.zip",
                    "x86": "https://windows.php.net/downloads/releases/php-7.4.33-Win32-vc15-x86.zip"
                },
                "8.3.8": {
                    "x64": "https://windows.php.net/downloads/releases/php-8.3.8-Win32-vs16-x64.zip",
                    "x86": "https://windows.php.net/downloads/releases/php-8.3.8-Win32-vs16-x86.zip"
                }
            }
        },
        "installComposer": {
            "url": "https://getcomposer.org/Composer-Setup.exe"
        },
        "installNodeJs": {
            "nvmInstallScript": "https://github.com/coreybutler/nvm-windows/releases/download/1.1.10/nvm-setup.exe"
        },
        "installGit": {
            "url": {
                "x64": "https://github.com/git-for-windows/git/releases/download/v2.45.2.windows.1/Git-2.45.2-64-bit.exe",
                "x86": "https://github.com/git-for-windows/git/releases/download/v2.45.2.windows.1/Git-2.45.2-32-bit.exe"
            }
        },
        "installDocker": {
            "url": "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe"
        },
        "projects": {
            "DMA": {
                "repoUrl": "https://github.com/healexsystems/cds",
                "branchName": "asz/dma-latest",
                "setupSteps": [
                    {
                        "type": "copyFile",
                        "source": "apps/dma-ukk/dev-ops/stacks/.env.template",
                        "destination": "apps/dma-ukk/dev-ops/stacks/.env.dev"
                    },
                    {
                        "type": "copyFile",
                        "source": "apps/dma-ukk/dev-ops/stacks/.env.dev",
                        "destination": "apps/dma-ukk/dev-ops/stacks/.env.base"
                    },
                    {
                        "type": "yarn",
                        "commands": [
                            "install",
                            "dma:build",
                            "docker:build:cds",
                            "docker:build:dma"
                        ]
                    }
                ],
                "startCommands": [
                    {
                        "type": "powershell",
                        "command": "yarn dev:backend:start",
                        "path": "apps/dma-ukk"
                    },
                    {
                        "type": "powershell",
                        "command": "yarn dev:ui:start",
                        "path": "apps/dma-ukk/ui"
                    }
                ]
            },
            "SF": {
                "repoUrl": "https://github.com/healexsystems/cds",
                "setupSteps": [
                    {
                        "type": "copyFile",
                        "source": "apps/sf/backend/.env.template",
                        "destination": "apps/sf/backend/.env"
                    },
                    {
                        "type": "copyFile",
                        "source": "apps/sf/frontend/.env-template",
                        "destination": "apps/sf/frontend/.env"
                    },
                    {
                        "type": "pnpm",
                        "commands": [
                            "exec docker:up:db",
                            "exec docker:up:build"
                        ],
                        "path": "apps/sf/backend"
                    },
                    {
                        "type": "pnpm",
                        "commands": [
                            "exec docker:up:build"
                        ],
                        "path": "apps/sf/frontend"
                    }
                ],
                "startCommands": [
                    {
                        "type": "powershell",
                        "command": "pnpm dev:backend:start",
                        "path": "apps/sf/backend"
                    },
                    {
                        "type": "powershell",
                        "command": "pnpm dev:ui:start",
                        "path": "apps/sf/frontend"
                    }
                ]
            }
        }
    }
}
