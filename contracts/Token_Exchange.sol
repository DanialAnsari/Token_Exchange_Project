pragma solidity ^0.6.0;

import "./IERC20.sol"
import "./Address.sol"

contract Token_exchange{

    private uint256 sellid_counter=0;
    private uint256 buyid_counter=0;
    private uint256 negotiate_counter=0;

    enum askingValueForm{
        ETHER,
        TOKEN
    }


    enum requestStatus{
        FOR-SALE,
        CLOSED,
    }

    enum counterRequestStatus{
        REJECTED,
        ACCEPTED,
        PENDING
    }

    struct sellRequest{
        address token2Sell;
        uint256 amount;
        askingValueForm form;
        uint256 askingValue;
        address token2Exchange;
        address seller;
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
        address buyer;
        string comment;
        requestStatus status;
    } 

    mapping(uint256=>sellRequest) public sellRequests;
    mapping(uint256=>counterRequest) public counterRequests;
    mapping(uint256=>buyRequest) public acceptRequests;


    function registerRequest(address _token2Sell , uint256 _amount ,uint256 _quantity ,askingValueForm _form, uint256 _askingValue , address _token2Exchange) external returns(uint256 id){
        require(Address.isContract);
        sellRequest memory request;
        request.token2Sell=_token2Sell;
        request.amount=_amount;
        if(_form==askingValueForm.ETHER;){
            request.token2Exchange=null;
        }
        else{;
            request.token2Exchange=_token2Exchange; 
        }
        request.askingValue=_askingValue;
        request.sender=msg.sender;
        request.status=requestStatus.Pending;
        sellRequests[sellid_counter]=request;
        IERC20 tokenAddress = IERC20(_token2Sell)
        request.quantity=_quantity;
        tokenAddress.transferFrom(msg.sender,address(this),(_amount*_quantity));

        emit sellRequestRegistered(sellid_counter,_token2Sell , _amount,_quantity , _form, _askingValue , _token2Exchange , msg.sender , request.status)
        sellid_counter++;

        return (sellid_counter-1);
    }

    function buySellRequest(uint256 _sellid ) external(returns uint256){
        require(sellRequests[_sellId].status==requestStatus.FOR-SALE,"This Sell Request is no longer for sale");
        require(msg.sender!=sellRequest[_sellid].seller,"Seller cannot Accept his own offer");
        require(!Address.isContract(msg.sender),"Offer cannot be accepted by a contract");
        
        uint256 amount;
        if(sellRequests[_sellId].form==askingValueForm.TOKEN){
            
            IERC20 tokenAddress=IERC20(sellRequests[_sellId].token2Exchange);
            amount= sellRequests[_sellId].askingValue;
            require(tokenAddress.balanceOf(msg.sender)>=amount,"You dont have the funds to buy this token");
            
            tokenAddress.transferFrom(msg.sender,sellRequests[_sellId].seller,amount);
            }
        else{
            amount= sellRequests[_sellId].askingValue;
            require(msg.sender.balance>=amount,"You dont have the funds to buy this token");
            msg.sender.transfer(payable(sellRequests[_sellId].seller));
            }

        sellRequests[_sellid].quantity-=1;
        if(sellRequests[_sellid].quantity<=0){
            sellRequests[_sellid].status=requestStatus.Closed;
        }
        buyRequest memory request;
        request.sellRequestID=_sellid;
        request.buyer=msg.sender;
        

        buyRequests[buyid_counter]=request;
        emit acceptRequestAltered(buyid_counter,_sellid , msg.sender);
        buyid_counter++;

        recieveAssets(_sellid)


        
        emit sellRequestRegistered(_sellid,sellRequest[_sellid].token2Sell , sellRequest[_sellid].amount,sellRequest[_sellid].quantity ,sellRequest[_sellid].quantity, sellRequest[_sellid].form, sellRequest[_sellid].askingValue , sellRequest[_sellid].token2Exchange ,sellRequest[_sellid].seller , sellRequest[_sellid].status)
        
        return (buyid_counter-1)


    }

    




    function recieveAssets(uint _sellid) external{
        address seller=sellRequests[_sellid].seller;
        address buyer=acceptRequests[_sellid].buyer;
        IERC20 token2sell=IERC20(sellRequests[_sellid].token2Sell);
        uint256 amount=sellRequests[_sellid].amount;

        token2sell.transfer(msg.sender,amount);

    }

    function negotiateRequest(uint256 _sellid , uint256 _askingValue , string memory _comment ) external returns{
        require(msg.sender.balance>=_askingValue,"You do not have the funds to make such an offer");
        counterRequest request;
        request.sellRequestID=_sellid;
        request.askingValue=_askingValue
        request.comment=_comment;
        request.status=counterRequestStatus.PENDING;

        counterRequests[negotiate_counter]=request;
        emit counterRequestAltered(negotiate_counter,_sellid, _askingValue  , _comment , request.status )
        msg.sender.transfer(address(this),_askingValue ether);
        negotiate_counter++;
        return (negotiate_counter-1);
    }

    function acceptNegotiatedRequest(uint256 _id) external {
        uint256 sell_id = counterRequests[_id].sellRequestID;
        require(sellRequests[sell_id].sender==msg.sender,"Only Seller can Accept ")
    }


    
    event sellRequestAltered(uint256 _id,address _token2Sell , uint256 _amount,uint256 quantity , askingValueForm _form, uint256 _askingValue , address _token2Exchange , address _seller , requestStatus _status);

    event acceptRequestAltered(uint256 _id, address _buyer , paymentStatus _status);

    event counterRequestAltered(uint256 id , uint256 sell_id, uint256 _askingValue  , string _comment , counterRequestStaus _status);
}