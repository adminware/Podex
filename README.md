## Podex - PowerShell/Pode + htmx Framework for Building Web Applications

### Table of Contents

-   [Introduction](#introduction)
-   [Features](#features)
-   [Technical Stack](#technical-stack)
-   [Setup](#setup)
-   [Running the Project](#running-the-project)
-   [Contributing](#contributing)
-   [License](#license)

### Introduction

Podex is a framework for building full-stack web applications using PowerShell/Pode for the backend and htmx for the frontend.

### Technical Stack

-   **Backend**: [PowerShell Core](https://github.com/PowerShell/PowerShell), [Pode](https://github.com/Badgerati/Pode), [SQLite](https://www.sqlite.org/index.html)
-   **Frontend**: [htmx](https://htmx.org/), [Mustache](https://mustache.github.io/), [Tailwind CSS](https://tailwindcss.com/)

### Setup

1. Clone the repository:

    ```sh
    git clone https://github.com/NomadicDaddy/podex.git
    cd podex
    ```

2. Install dependencies:

    ```sh
    npm install
    ```

3. Install PowerShell modules:
    ```sh
    powershell -Command ". ./.build.ps1"
    ```

### Running the Project

1. Start the server:

    ```sh
    npm start
    ```

2. Open your browser and navigate to `http://localhost:8433`.

### Contributing

1. Fork the repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Make your changes.
4. Commit your changes (`git commit -am 'Add new feature'`).
5. Push to the branch (`git push origin feature-branch`).
6. Create a new Pull Request.

### License

This project is licensed under the MIT License.
