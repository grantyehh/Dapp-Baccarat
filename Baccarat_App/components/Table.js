import style from '../styles/Table.module.css'
import TableRow from './TableRow'
import { useAppContext } from '../context/context'
const Table = () => {
  const { checkPlayers,GamingResult,Whowin } = useAppContext()
  return (
    <div className={style.wrapper}>
      <div className={style.tableHeader}>
        <span className={style.addressTitle}>🃏 Game Result (若牌序最後出現14，代表該家沒有補牌)</span>
        <span className={style.amountTitle}>💲 Win money</span>
        
      </div>
      <div className={style.rows}>
        {checkPlayers == true ? (
          <TableRow result={GamingResult} />
        ) : (
          <button className={style.btn} onClick={Whowin}>See Result</button>
        )}
      </div>
    </div>
  )
}
export default Table
