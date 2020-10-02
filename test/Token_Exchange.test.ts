import {expect, use} from 'chai';
import {Contract} from 'ethers';
import {deployContract, MockProvider, solidity} from 'ethereum-waffle';
import Token_exchange from '../build/Token_exchange.json';

use(solidity);

describe('registerRequest', () => {
    const [wallet, walletTo] = new MockProvider().getWallets();
    let token: Contract;

    before(async () => {
        token = await deployContract(wallet, Token_exchange);
      });

      it('Register Sell Request', async () => {
          await token.registerRequest('0xFa7cC076A450C7E06814702F845DDB9e3d13CF73',100,5,)
        expect(await token.balanceOf(wallet.address)).to.equal(1000);
      });



  
}
