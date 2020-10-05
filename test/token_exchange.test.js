
chai=require('chai');
Contract= require('ethers');
waffle=require('ethereum-waffle');
Token_exchange=require('../build/Token_exchange.json');
ERC201=require('../build/ERC20.json');
ERC202=require('../build/ERC20.json');


//console.log(waffle)
chai.use(waffle.solidity);

describe('Token_Exchange', () => {
  const [wallet, walletTo] = new  waffle.MockProvider().getWallets();
  let exchangeCon= Contract;
  let token1= Contract;
  let token2= Contract;

  before(async () => {

    exchangeCon = await waffle.deployContract(wallet, Token_exchange);
    token1= await waffle.deployContract(wallet, ERC201); 
    token2= await waffle.deployContract(wallet, ERC202);
    
    
    //console.log(token1.address)
  });

  it('Check if Quantity is being updated', async () => {
    await token1.approve(exchangeCon.address,1000);
    
    await exchangeCon.registerOrder(token1.address,100,4,0,2,"0x0000000000000000000000000000000000000000");
    //console.log(await exchangeCon.SellOrders(0))
    value=await exchangeCon.SellOrders(0);
    //console.log(value[6].toString())
   chai.expect(value[6].toString()).to.equal("4");
  });

  it('Check if Address is being updated', async () => {

   chai.expect(value[0].toString()).to.equal(token1.address);
  });

  it('Check if Amount is being updated', async () => {

   chai.expect(value[1].toString()).to.equal("100");
  });

  it('Check if Payment Option is being updated when ether is selected', async () => {

    chai.expect(value[2].toString()).to.equal("0");
   });

   it('Check if Payment Option is being updated when Token is selected', async () => {
    await exchangeCon.registerOrder(token1.address,100,4,1,2,token2.address);
    value=await exchangeCon.SellOrders(1);
    chai.expect(value[2].toString()).to.equal("1");
   });
   
   it('Check if Order can be Negotiated', async () => {

    await exchangeCon.negotiate(0,1,"Paisa Kam karo");
    value=await exchangeCon.CounterOrders(0);
    console.log(value)
    chai.expect(value[1].toString()).to.equal("1");
   
   });

   it('Check if Orders are being increamented', async () => {

    await exchangeCon.increamentQuantity(0,3);

    value=await exchangeCon.SellOrders(0);
    //console.log(value[6].toString())
    chai.expect(value[6].toString()).to.equal("7");
   });

   it('Check if Orders are being decreamented', async () => {

    await exchangeCon.decreamentQuantity(0,5);

    value=await exchangeCon.SellOrders(0);
    //console.log(value[6].toString())
    chai.expect(value[6].toString()).to.equal("0");
   });

   it('Check if Counter Order event is being emitted', async () => {

    
    chai.expect(exchangeCon.negotiate(0,1,"Paisa Kam karo"))
    .to.emit(exchangeCon, 'CounterOrderAltered')
    .withArgs(0,0,1,"Paisa Kam karo");
   });
   

  it('Check if Sent Order event is being emitted', async () => {

    
    chai.expect(exchangeCon.registerOrder(token1.address,100,4,0,2,"0x0000000000000000000000000000000000000000"))
    .to.emit(exchangeCon, 'SellOrderAltered')
    .withArgs(2,token1.address.toString(),100,4,0,2,"0x0000000000000000000000000000000000000000",wallet.address.toString(),0);
   });






   

//   it('Check if ', async () => {
//     await token1.approve(exchangeCon.address,1000);
//     //console.log(exchangeCon)
//     await exchangeCon.registerOrder(token1.address,100,3,0,2,"0x0000000000000000000000000000000000000000");
//     let value=await exchangeCon.getQuantity(0);
//     console.log(value);
//     chai.expect(await exchangeCon.getQuantity(0)).to.equal(3);
//   });

  });