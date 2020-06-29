(async () => {

  const process = require('process')


  console.log("env", process.env)

  // const isYarn = process.env.npm_execpath.match(/yarn\.js$/)

  const genInstallComand = (platform) => 
      `npm install electron@7.1.14 --save-dev --platform=${platform} -d`

  const cwd = process.cwd()
  try {

    const inquirer = require('inquirer')
    const child_process = require('child_process')
    const { platform } = require('os')
    const path = require('path')
    const fs = require('fs')
    const packageJsonPath = path.join(__dirname, '../package.json')
    console.log("packagePath", packageJsonPath)
    const packageJson = require(packageJsonPath)
    const firstPrompt = [{
      type: 'checkbox',
      message: 'Platform',
      name: 'basic',
      choices: [
        {
          name: 'electron',
        },
        {
          name: 'web',
          checked: true,
        }
      ]
    }]

    let {basic} = await inquirer.prompt(firstPrompt)

    const config = {
      platform: basic,
    }

    if (basic.includes('electron')) {
      const secondPrompt = [{
        type: 'rawlist',
        name: 'platform',
        message: 'Electron platform ?',
        choices: [
          'macOS',
          'win32',
        ]
      }]

      let {platform} = await inquirer.prompt(secondPrompt);
      packageJson.dependencies = {
        "adm-zip": "^0.4.14",
        "agora-electron-sdk": "education290"
      }
      packageJson.devDependencies = {
        ...packageJson.devDependencies,
        electron: '7.1.14',
        'electron-builder': '22.5.1'
      }

      if (platform === 'macOS') {
        packageJson.agora_electron.platform = 'darwin'
        packageJson.agora_electron.arch = 'x64'
        fs.writeFileSync(packageJsonPath, JSON.stringify(packageJson, null, 2))
        child_process.execSync(`cd ${cwd}`);
        child_process.execSync(genInstallComand('darwin'), {stdio: [0, 1, 2]})
        // process.exit(0);
        return
      }

      if (platform === 'win32') {
        packageJson.agora_electron.platform = 'win32'
        packageJson.agora_electron.arch = 'ia32'
        fs.writeFileSync(packageJsonPath, JSON.stringify(packageJson, null, 2))
        child_process.execSync(`cd ${cwd}`);
        child_process.execSync(genInstallComand('win32'), {stdio: [0, 1, 2]})
        return
      }
    } else {
      packageJson.dependencies = undefined
      packageJson.devDependencies = {
        ...packageJson.devDependencies,
        electron: undefined,
        'electron-builder': undefined
      }
      // process.exit(0);
      return
    }
  } catch (err) {
    console.warn(err)
  }
})()