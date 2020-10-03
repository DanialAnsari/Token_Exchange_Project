//import {expect, use} from 'chai';
var chai = require("chai");
//import {Contract} from 'ethers';
var ethers = require("ethers");
//import {deployContract, MockProvider, solidity} from 'ethereum-waffle';
var waffle = require('ethereum-waffle') ;
//import Token_exchange from '../build/Token_exchange.json';
var Token_exchange = require('../build/Token_exchange.json');
var ERC201= require('../build/ERC20.json');
var ERC202= require('../build/ERC20.json');

chai.use(waffle.solidity);

describe('registerRequest', () => {
    const [wallet, walletTo] = new waffle.MockProvider().getWallets();
    let exchangeCon ;
    let token1;
    let token2;


    before(async () => {
        exchangeCon = await waffle.deployContract(wallet, Token_exchange);
        token1= await waffle.deployContract(wallet, ERC201);
        
        
        
        token2= await waffle.deployContract(wallet, ERC202);
        
        console.log("Hello")
        console.log(token1.address)
        exchangeCon.initialize();
        //console.log(token)
      });

      it('Register Sell Request', async () => {
        
        
        await token1.approve(exchangeCon.address,1000);
        console.log(exchangeCon)
        await exchangeCon.registerRequest(token1.address,100,5,0,2);
        chai.expect(await exchangeCon.sellRequests[0].quantity).to.equal(5);
      });
  
});
