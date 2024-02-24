import style from '../styles/PotCard.module.css'

import { useAppContext } from '../context/context'

const LotteryCard = () => {
  // TODO: Get the data needed from context
  const {choosebanker,chooseplayer,chooseTie,chooseBankerPair, choosePlayerPair, ChooseWinner} =useAppContext()
  return (
    <div className={style.wrapper}>
      <div className={style.TitleWrapper}>
        <span className={style.title}>江西南沒有授權 </span>
        <span className={style.InputTitle}>💲 Choose your bet 💲</span>
        <span className={style.EntryFeeNotice}>入場費 : 0.00001 sepolia ETH</span>
       </div>
      {/* TODO: Add onClick functionality to the butt`ons */}
      <button className={style.btn} onClick={choosebanker}>0: 下注莊家贏 </button>
      <button className={style.btn} onClick={chooseplayer}>1: 下注閒家贏</button>
      <button className={style.btn} onClick={chooseTie}>2: 下注平手</button>
      <button className={style.btn} onClick={chooseBankerPair}>3: 下注莊對子</button>
      <button className={style.btn} onClick={choosePlayerPair}>4: 下注閒對子</button>
      <button className={style.btn} onClick={ChooseWinner}> 選擇贏家(僅百家樂合約擁有者使用)</button>
    </div>
    
  )
}
export default LotteryCard
