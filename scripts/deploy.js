const path = require('path');
const Web3 = require('web3');
const HDWalletProvider = require('truffle-hdwallet-provider');
const consola = require('consola');

const contractPath = path.resolve(__dirname, '../compiled/Car.json');
const { interface, bytecode } = require(contractPath);
console.log(interface);
const provider = new HDWalletProvider(
    'slab gadget motor monkey island symptom book battle beyond section know poverty',
    'https://rinkeby.infura.io/hLV2Ay1wJwLSk0vAzMTr'
)

const web3 = new Web3(provider);

(async () => {
    console.time('Deployment time')
    const accounts = await web3.eth.getAccounts();
    consola.success(`Account:${accounts[0]}`);

    consola.start('Deployment start')
    
    const result = await new web3.eth.Contract(JSON.parse(interface))
    .deploy({data: bytecode, arguments:['AUDI']})
    .send({from: accounts[0], gas:'1000000'})
    

    consola.success(`Contract has been depolyed:${result.options.address}`)
    console.timeEnd('Deployment time')
})()