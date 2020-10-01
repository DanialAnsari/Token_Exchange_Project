import {expect, use} from 'chai';
import {Contract} from 'ethers';
import {deployContract, MockProvider, solidity} from 'ethereum-waffle';
import BasicToken from '../build/Token_exchange.json';

use(solidity);
