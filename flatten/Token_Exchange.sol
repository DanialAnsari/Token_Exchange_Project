// Dependency file: contracts/IERC20.sol

// pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * // importANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


// Dependency file: contracts/Address.sol



// pragma solidity ^0.6.2;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [// importANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * // importANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// Dependency file: contracts/SafeMath.sol

// pragma solidity ^0.6.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// Root file: contracts/Token_Exchange.sol

pragma solidity ^0.6.0;

// import "contracts/IERC20.sol";
// import "contracts/Address.sol";
// import "contracts/SafeMath.sol";

contract Token_exchange{

     uint256 sellid_counter=0;
     uint256 buyid_counter=0;
     uint256 negotiate_counter=0;

    enum askingValueForm{
        ETHER,
        TOKEN
    }


    enum requestStatus{
        FORSALE,
        CLOSED
    }

    enum counterRequestStatus{
        REJECTED,
        ACCEPTED,
        PENDING,
        CANCELED,
        CLOSED
    }

    struct sellRequest{
        address tokenToSell;
        uint256 amount;
        askingValueForm form;
        uint256 askingValue;
        address tokenToExchange;
        address payable seller;
        uint256 quantity;
        requestStatus status;
    }

    struct buyRequest{
        uint256 sellRequestID;
        address buyer;
        
    }

    struct counterRequest{
        uint256 sellRequestID;
        uint256 askingValue;
        address payable buyer;
        string comment;
        counterRequestStatus status;
    } 

    mapping(uint256=>sellRequest) public sellRequests;
    mapping(uint256=>counterRequest) public counterRequests;
    mapping(uint256=>buyRequest) public acceptRequests;


    function registerRequest(address _tokenToSell , uint256 _amount ,uint256 _quantity ,askingValueForm _form, uint256 _askingValue , address _tokenToExchange) external returns(uint256 id){
        require(!Address.isContract(msg.sender),"Seller cannot be a contract");
        sellRequest memory request;
        request.tokenToSell=_tokenToSell;
        request.amount=_amount;
  
        request.tokenToExchange=_tokenToExchange; 
        

        request.askingValue=SafeMath.mul(_askingValue,1000000000000000000);
        request.seller=msg.sender;
        request.status=requestStatus.FORSALE;
        request.quantity=_quantity;
        sellRequests[sellid_counter]=request;
        IERC20 tokenAddress = IERC20(_tokenToSell);
        
        tokenAddress.transferFrom(msg.sender,address(this),(SafeMath.mul(_amount,_quantity)));

        emit sellRequestAltered(sellid_counter,_tokenToSell , _amount,_quantity , _form, _askingValue , _tokenToExchange , msg.sender , request.status);
        sellid_counter=SafeMath.add(sellid_counter,1);

        return (SafeMath.sub(sellid_counter,1));
    }


    function registerRequest(address _tokenToSell , uint256 _amount ,uint256 _quantity ,askingValueForm _form, uint256 _askingValue) external returns(uint256 id){
        require(Address.isContract(msg.sender)==false,"Seller cannot be a contract");
        sellRequest memory request;
        request.tokenToSell=_tokenToSell;
        request.amount=_amount;


        request.askingValue=SafeMath.mul(_askingValue,1000000000000000000);
        request.seller=msg.sender;
        request.status=requestStatus.FORSALE;
        request.quantity=_quantity;
        sellRequests[sellid_counter]=request;
        
        IERC20 tokenAddress = IERC20(_tokenToSell);
        
        tokenAddress.transferFrom(msg.sender,address(this),(SafeMath.mul(_amount,_quantity)));

        emit sellRequestAltered(sellid_counter,_tokenToSell , _amount,_quantity , _form, _askingValue , address(0x0) , msg.sender , request.status);
        sellid_counter=SafeMath.add(sellid_counter,1);

        return (SafeMath.sub(sellid_counter,1));
    }

    function recieveAssets(uint256 _sellid) public {
        address seller=sellRequests[_sellid].seller;
        IERC20 tokenToSell=IERC20(sellRequests[_sellid].tokenToSell);
        uint256 amount=sellRequests[_sellid].amount;
        tokenToSell.transfer(msg.sender,amount);

    }

    function buySellRequest(uint256 _sellid ) payable external returns (uint256){
        require(sellRequests[_sellid].status==requestStatus.FORSALE,"This Sell Request is no longer for sale");
        require(msg.sender!=sellRequests[_sellid].seller,"Seller cannot Accept his own offer");
        require(!Address.isContract(msg.sender),"Offer cannot be accepted by a contract");
        
        uint256 amount;
        if(sellRequests[_sellid].form==askingValueForm.TOKEN){
            
            IERC20 tokenAddress=IERC20(sellRequests[_sellid].tokenToExchange);
            amount= sellRequests[_sellid].askingValue;
            require(tokenAddress.balanceOf(msg.sender)>=amount,"You dont have the funds to buy this token");
            
            tokenAddress.transferFrom(msg.sender,sellRequests[_sellid].seller,amount);
            }
        else{
            amount= sellRequests[_sellid].askingValue;
            require(msg.value==amount,"You dont have the funds to buy this token");
            sellRequests[_sellid].seller.call{value: msg.value}("");
            }
        

        sellRequests[_sellid].quantity=SafeMath.sub(sellRequests[_sellid].quantity,1);
        if(sellRequests[_sellid].quantity<=0){
            sellRequests[_sellid].status=requestStatus.CLOSED;
        }
        buyRequest memory request;
        request.sellRequestID=_sellid;
        request.buyer=msg.sender;
        

        acceptRequests[buyid_counter]=request;
        emit acceptRequestAltered(buyid_counter,_sellid , msg.sender);
        buyid_counter=SafeMath.add(buyid_counter,1);

        recieveAssets(_sellid);


        
        emit sellRequestAltered(_sellid,sellRequests[_sellid].tokenToSell , sellRequests[_sellid].amount,sellRequests[_sellid].quantity, sellRequests[_sellid].form, sellRequests[_sellid].askingValue , sellRequests[_sellid].tokenToExchange ,sellRequests[_sellid].seller , sellRequests[_sellid].status);
        
        return (SafeMath.sub(buyid_counter,1));


    }

    






    function negotiateRequest(uint256 _sellid , uint256 _askingValue , string calldata _comment ) external returns(uint256) {
        require(msg.sender.balance>=_askingValue,"You do not have the funds to make such an offer");
        counterRequest memory request;
        request.sellRequestID=_sellid;
        request.buyer=msg.sender;
        request.askingValue=_askingValue;
        request.comment=_comment;
        request.status=counterRequestStatus.PENDING;

        counterRequests[negotiate_counter]=request;
        emit counterRequestAltered(negotiate_counter,_sellid, _askingValue  , _comment , request.status );
        negotiate_counter++;
        return (negotiate_counter-1);
    }

    function acceptCounterRequest(uint256 _id) external {
        uint256 sell_id = counterRequests[_id].sellRequestID;
        require(sellRequests[sell_id].seller==msg.sender,"Only Seller can Accept a Counter Request");
        address buyer=counterRequests[_id].buyer;
        address seller= sellRequests[sell_id].seller;
  
        counterRequests[_id].status=counterRequestStatus.ACCEPTED;
        }

    function buyCounterRequest(uint256 _id) external payable{
        uint256 _sellid = counterRequests[_id].sellRequestID;
        require(counterRequests[_id].status==counterRequestStatus.ACCEPTED,"Counter Request must be accepted");
        
        require(msg.sender==counterRequests[_id].buyer);
        
        uint256 amount;
        IERC20 tokenToSell=IERC20(sellRequests[_sellid].tokenToSell);
        amount=sellRequests[_sellid].amount;
        tokenToSell.transfer(msg.sender,amount);

        sellRequests[_sellid].quantity=SafeMath.sub(sellRequests[_sellid].quantity,1);
        if(sellRequests[_sellid].quantity<=0){
            sellRequests[_sellid].status=requestStatus.CLOSED;
        }

        
        if(sellRequests[_sellid].form==askingValueForm.TOKEN){
            
            IERC20 tokenAddress=IERC20(sellRequests[_sellid].tokenToExchange);
            amount= counterRequests[_sellid].askingValue;
            require(tokenAddress.balanceOf(msg.sender)>=amount,"You dont have the funds to buy this token");
            require(tokenAddress.allowance(msg.sender,address(this))>=amount,"Buyer needs to approve required tokens to contract first");
            tokenAddress.transferFrom(msg.sender,sellRequests[_sellid].seller,amount);
            }
        else{
            amount= counterRequests[_sellid].askingValue;
            require(msg.value>=amount,"You dont have the funds to buy this token");
            sellRequests[_sellid].seller.call{value: msg.value}("");
            }
    

        // sellRequests[sell_id].quantity-=1;
        // if(sellRequests[sell_id].quantity<=0){
        //     sellRequests[sell_id].status=requestStatus.CLOSED;
        // }

        emit counterRequestAltered(_id,_sellid, counterRequests[_sellid].askingValue  , counterRequests[_id].comment , counterRequests[_id].status );
        emit sellRequestAltered(_sellid,sellRequests[_sellid].tokenToSell , sellRequests[_sellid].amount ,sellRequests[_sellid].quantity, sellRequests[_sellid].form, sellRequests[_sellid].askingValue , sellRequests[_sellid].tokenToExchange ,sellRequests[_sellid].seller , sellRequests[_sellid].status);
    }


    function cancelCounterRequest(uint256 _id) external {
        uint256 sell_id = counterRequests[_id].sellRequestID;
        address buyer=counterRequests[_id].buyer;
        address seller= sellRequests[sell_id].seller;
        require(msg.sender==seller || msg.sender==buyer,"Only Seller or Owner of the Counter request can cancel couterRequest");



        if(msg.sender==seller){
            counterRequests[sell_id].status=counterRequestStatus.REJECTED;
        }
        else if(msg.sender==buyer){
            counterRequests[sell_id].status=counterRequestStatus.CANCELED;
        }

         emit counterRequestAltered(_id,sell_id, counterRequests[_id].askingValue  , counterRequests[_id].comment , counterRequests[_id].status );
    }

    function depositRequests(uint256 sell_id , uint256 quantity) external{
        require(sellRequests[sell_id].seller==msg.sender,"Only Seller of these requests can deposit Requests");
        SafeMath.add(sellRequests[sell_id].quantity, quantity);
        IERC20 tokenToSell = IERC20(sellRequests[sell_id].tokenToSell);
        uint256 amount=sellRequests[sell_id].amount;
        require(tokenToSell.balanceOf(msg.sender)>=SafeMath.mul(amount,quantity),"Seller must have the funds being put for sale");
        if(sellRequests[sell_id].status==requestStatus.CLOSED){
            sellRequests[sell_id].status=requestStatus.FORSALE;
        }


        tokenToSell.transferFrom(msg.sender,address(this),amount*quantity);
        emit sellRequestAltered(sell_id,sellRequests[sell_id].tokenToSell , sellRequests[sell_id].amount,sellRequests[sell_id].quantity, sellRequests[sell_id].form, sellRequests[sell_id].askingValue , sellRequests[sell_id].tokenToExchange ,sellRequests[sell_id].seller , sellRequests[sell_id].status);

    }

    function withdrawRequests(uint256 sell_id , uint256 quantity) external{
        require(sellRequests[sell_id].seller==msg.sender,"Only Seller of these requests can withdraw Requests");
        require(sellRequests[sell_id].quantity>=quantity,"Seller must have enough requests deposited to withdraw the specific amount");

        IERC20 tokenToSell=IERC20(sellRequests[sell_id].tokenToSell);
        uint256 amount= sellRequests[sell_id].amount;

        tokenToSell.transfer(msg.sender,SafeMath.mul(amount,quantity));
        sellRequests[sell_id].quantity-=quantity;

        if(sellRequests[sell_id].quantity<=0){
            sellRequests[sell_id].status=requestStatus.CLOSED;
        }
        emit sellRequestAltered(sell_id,sellRequests[sell_id].tokenToSell , sellRequests[sell_id].amount ,sellRequests[sell_id].quantity, sellRequests[sell_id].form, sellRequests[sell_id].askingValue , sellRequests[sell_id].tokenToExchange ,sellRequests[sell_id].seller , sellRequests[sell_id].status);
    }


    

    


    
    event sellRequestAltered(uint256 _id,address _tokenToSell , uint256 _amount,uint256 quantity , askingValueForm _form, uint256 _askingValue , address _tokenToExchange , address _seller , requestStatus _status);

    event acceptRequestAltered(uint256 _id ,uint256 sell_id, address _buyer);

    event counterRequestAltered(uint256 id , uint256 sell_id, uint256 _askingValue  , string _comment , counterRequestStatus _status);
}