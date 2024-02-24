import { createContext, useState, useEffect, useContext } from 'react'
import Web3 from 'web3'
import createLotteryContract from '../utils/lotteryContract'


export const appContext = createContext()

export const AppProvider = ({ children }) => {
  const [address,setAddress] = useState('');
  const [web3,setWeb3] = useState();
  const [lotteryContract,setLotteryContract] =useState();
  const [checkPlayers,setCheckPlayers] = useState(false);
  const [GamingResult,setGamingResult] = useState([]);
  const [ResultNotReadym, setResultNotReady] = useState(false);
  const owner = '0x14583723c0A21C3f115D552C773D2C19b8B0a7D3';

  useEffect(()=>{
     //updateLottery()
     connectWallet()
  },[lotteryContract])

  //Update the Result block
  const updateLottery = async()=>{
    if(lotteryContract){
      
      // setLotteryPlayers(await lotteryContract.methods.getPlayers().call())
      // setGamingResult(await lotteryContract.methods.checkResult().call())
    }
  }
  
  const connectWallet =async() =>{
    // Check if MetaMask is installed
    if(typeof window !== 'undefined' && typeof window.ethereum !=='undefined'){
       try {
        // request wallet connection
        await window.ethereum.request({method:'eth_requestAccounts'})
        // create web3 instance & set to state
        const web3 =new Web3(window.ethereum)
        // set web3 instance in React state
        setWeb3(web3)
        // get list of accounts
        const accounts =await web3.eth.getAccounts(); 
        // set account 1 to React state
        setAddress(accounts[0])
        setLotteryContract(createLotteryContract(web3))
        window.ethereum.on('accountsChanged',async() =>{
          const accounts =await web3.eth.getAccounts()
          // set account 1 to react state
          setAddress(accounts[0])
        })
       } catch (error) {
        console.log(error,'connect wallet');
       }
    }else{
      console.log('Please install Metamask')
    }
  }

  // Choose banker win
  async function ChooseWinner() {
    try {
      await lotteryContract.methods.ChooseWinner().send({
        from: address,
        gas:500000,
        gasLimit: 60000000
      })
    } catch (error) {
      console.log(error)
    }
}


  // Choose banker win
  async function choosebanker() {
      try {
        await lotteryContract.methods.enter_Banker().send({
          from:address,
          value:web3.utils.toWei('0.00001','ether'),
          gas: 3000000,
          gasPrice: null,
        })
        
      } catch (error) {
        console.log(error)
      }
  }
  // Choose player win
  async function chooseplayer() {
    try {
      await lotteryContract.methods.enter_Player().send({
        from:address,
        value:web3.utils.toWei('0.00001','ether'),
        gas: 3000000,
        gasPrice: null,
      })
      
    } catch (error) {
      console.log(error)
    }
  }
  // Choose Tie
  async function chooseTie() {
    try {
      await lotteryContract.methods.enter_Tie().send({
        from:address,
        value:web3.utils.toWei('0.00001','ether'),
        gas: 3000000,
        gasPrice: null,
      })
      
    } catch (error) {
      console.log(error)
    }
  }
  
  async function chooseBankerPair() {
    try {
      await lotteryContract.methods.enter_BankerPair().send({
        from:address,
        value:web3.utils.toWei('0.00001','ether'),
        gas: 3000000,
        gasPrice: null,
      })
      
    } catch (error) {
      console.log(error)
    }
  }

  async function choosePlayerPair() {
    try {
      await lotteryContract.methods.enter_PlayerPair().send({
        from:address,
        value:web3.utils.toWei('0.00001','ether'),
        gas: 3000000,
        gasPrice: null,
      })
      
    } catch (error) {
      console.log(error)
    }
  }

  //Choose player win
  const Whowin = async () => {
    try {
      setCheckPlayers(await lotteryContract.methods.playerExist().call({
        from:address,
        gas: 3000000,
        gasPrice: null
      }))
      
      setGamingResult(await lotteryContract.methods.checkResult().call({
        from:address,
        gas: 3000000,
        gasPrice: null,
      }))
      
      

      console.log(checkPlayers)
      console.log(GamingResult)
      //console.log(tx)
    } catch (err) {
      console.log(err, 'pick Winner')
    }
  }

  return <appContext.Provider value={{
     connectWallet,
     ChooseWinner,
     address,
     choosebanker,
     chooseplayer,
     chooseTie,
     chooseBankerPair,
     choosePlayerPair,
     Whowin,
     checkPlayers,
     GamingResult,
     owner
     }}>{children}</appContext.Provider>
}

export const useAppContext = () => {
  return useContext(appContext)
}
