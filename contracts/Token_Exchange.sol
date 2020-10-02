pragma solidity ^0.6.0;

import "./IERC20.sol";
import "./Address.sol";
import "./SafeMath.sol";

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
        sellRequests[sell_id].quantity=SafeMath.add(sellRequests[sell_id].quantity, quantity);
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