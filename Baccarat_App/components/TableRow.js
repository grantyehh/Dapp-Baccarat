import style from '../styles/TableRow.module.css'

//import result from
const TableRow = ({ result }) => {
 
  return (
    <div className={style.wrapper}>
      
      <div className={style.result}>莊家牌序:{result[0]} ; 莊家總和:{result[1]} ; 閒家牌序:{result[2]} ; 閒家牌總和:{result[3]} ; 玩家下注: {result[5]}</div>
      <div className={style.ethAmount}>
        <span className={style.goldAccent}>{result[4]}</span>
      </div>
    </div>
  )
}
export default TableRow
