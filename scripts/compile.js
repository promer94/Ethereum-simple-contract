const fs = require('fs-extra')
const path = require('path')
const solc = require('solc')
const signale = require('signale')

//cleanup
const compiledDir = path.resolve(__dirname, '../compiled')
fs.removeSync(compiledDir)
fs.ensureDirSync(compiledDir)

//search all contracts
const contractFiles = fs.readdirSync(path.resolve(__dirname, '../contracts'))
contractFiles.forEach(contractFile => {
  signale.time('Compile')
  //Compile
  signale.pending('Compiling....')
  const contractPath = path.resolve(__dirname, '../contracts', contractFile)
  const contractSource = fs.readFileSync(contractPath, 'utf8')
  const result = solc.compile(contractSource, 1)
  signale.info(`file compiled: ${contractFile}`)

  //Check errors
  if (Array.isArray(result.errors) && result.errors.length) {
    throw new Error(result.errors[0])
  }

  //save to disk
  Object.keys(result.contracts).forEach(name => {
    const contractName = name.replace(/^:/, '')
    const filePath = path.resolve(compiledDir, `${contractName}.json`)
    fs.outputJsonSync(filePath, result.contracts[name])
    signale.success(`Contract ${contractName} saved to ${filePath}`)
    signale.timeEnd('Compile')
  })
})
