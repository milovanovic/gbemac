package gbemac

import chisel3._
import chisel3.experimental._
import chisel3.util._

import dspblocks._
import freechips.rocketchip.amba.axi4._
import freechips.rocketchip.amba.axi4stream._
import freechips.rocketchip.config._
import freechips.rocketchip.diplomacy._
import freechips.rocketchip.regmapper._
import freechips.rocketchip.tilelink._

/*
case class TemacConfigParams
(
  sampleNumWidth: Int = 11,
  burstNumWidth: Int = 9,
  txNumWidth: Int = 4
)  {
  //require(sampleNumWidth > 0)
  //require(burstNumWidth > 0)
  //require(txNumWidth > 0)
}

object TemacParams {
  def apply(sampleNumWidth: Int, burstNumWidth: Int, txNumWidth: Int): TemacConfigParams = {
    require(sampleNumWidth > 0)
    require(burstNumWidth > 0)
    require(txNumWidth > 0)
    TemacConfigParams (
      sampleNumWidth = sampleNumWidth,
      burstNumWidth = burstNumWidth,
      txNumWidth = txNumWidth
    )
  }
}
*/

class TemacConfigIO () extends Bundle {

  val txHwmark = Output(UInt(5.W))
  val txLwmark = Output(UInt(5.W))
  val pauseFrameSendEn = Output(Bool())
  val pauseQuantaSet = Output(UInt(16.W))
  val macTxAddEn = Output(Bool())
  val fullDuplex = Output(Bool())
  val maxRetry = Output(UInt(4.W))
  val ifgSet = Output(UInt(6.W))
  val macTxAddPromData = Output(UInt(8.W))
  val macTxAddPromAdd = Output(UInt(3.W))
  val macTxAddPromWr = Output(Bool())
  val txPauseEn = Output(Bool())
  val xOffCpu = Output(Bool())
  val xOnCpu = Output(Bool())
  val macRxAddChkEn = Output(Bool())
  val macRxAddPromData = Output(UInt(8.W))
  val macRxAddPromAdd = Output(UInt(3.W))
  val macRxAddPromWr = Output(Bool())
  val broadcastFilterEn = Output(Bool())
  val broadcastBucketDepth = Output(UInt(16.W))
  val broadcastBucketInterval = Output(UInt(16.W))
  val rxAppendCrc = Output(Bool())
  val rxHwmark = Output(UInt(5.W))
  val rxLwmark = Output(UInt(5.W))
  val crcCheckEn = Output(Bool())
  val rxIfgSet = Output(UInt(6.W))
  val rxMaxLength = Output(UInt(16.W))
  val rxMinLength = Output(UInt(7.W))
  val cpuRdAddr = Output(UInt(6.W))
  val cpuRdApply = Output(Bool())
  val lineLoopEn = Output(Bool())
  val speed = Output(UInt(3.W))
  val divider = Output(UInt(8.W))
  val ctrlData = Output(UInt(16.W))
  val rgAd = Output(UInt(5.W))
  val fiAd = Output(UInt(5.W))
  val writeCtrlData= Output(Bool())
  val noPreamble = Output(Bool())
  val packetSize = Output(UInt(16.W))
  
  val srcMac = Output(UInt(48.W))
  val srcIp = Output(UInt(32.W))
  val srcPort = Output(UInt(16.W))
  val dstMac = Output(UInt(48.W))
  val dstIp = Output(UInt(32.W))
  val dstPort = Output(UInt(16.W))

  val ctrlStart = Output(Bool())
  val ctrlStop = Output(Bool())  
  val ctrlRst = Output(Bool())
}

class TemacConfig (csrAddress: AddressSet, beatBytes: Int) extends LazyModule()(Parameters.empty){ //[T <: Data : Real: BinaryRepresentation] 

  lazy val io = Wire(new TemacConfigIO)
  
  //val mem = Some(AXI4RegisterNode(address = csrAddress, beatBytes = beatBytes))
  val mem = Some(AXI4RegisterNode(address = csrAddress, beatBytes = beatBytes))
  //def regmap(mapping: (Int, Seq[RegField])*): Unit = mem.regmap(mapping:_*)
  
  lazy val module = new LazyModuleImp(this) {
    
    val fiAd = RegInit(UInt(5.W), 1.U)
    val rgAd = RegInit(UInt(5.W), 0.U)
    val ctrlData = RegInit(UInt(16.W), 0.U)
    val writeCtrlData= RegInit(Bool(), false.B)
    val noPreamble = RegInit(Bool(), false.B)
    val divider = RegInit(UInt(8.W), 0.U)
    val speed = RegInit(UInt(3.W), 4.U)
    val fullDuplex = RegInit(Bool(), true.B)
    val packetSize = RegInit(UInt(16.W), 1024.U)
    val txHwmark = RegInit(UInt(5.W), 9.U)
    val txLwmark = RegInit(UInt(5.W), 8.U)
    val pauseFrameSendEn = RegInit(Bool(), false.B)
    val pauseQuantaSet = RegInit(UInt(16.W), 0.U)
    val ifgSet = RegInit(UInt(6.W), 12.U)
    val maxRetry = RegInit(UInt(4.W), 2.U)
    val macTxAddEn = RegInit(Bool(), false.B)
    val macTxAddPromData = RegInit(UInt(8.W), 0.U)
    val macTxAddPromAdd = RegInit(UInt(3.W), 0.U)
    val macTxAddPromWr = RegInit(Bool(), false.B)
    val txPauseEn = RegInit(Bool(), false.B)
    val xOffCpu = RegInit(Bool(), false.B)
    val xOnCpu = RegInit(Bool(), false.B)
    val macRxAddChkEn = RegInit(Bool(), false.B)
    val macRxAddPromData = RegInit(UInt(8.W), 0.U)
    val macRxAddPromAdd = RegInit(UInt(3.W), 0.U)
    val macRxAddPromWr = RegInit(Bool(), false.B)
    val broadcastFilterEn = RegInit(Bool(), false.B)
    val broadcastBucketDepth = RegInit(UInt(16.W), 0.U)
    val broadcastBucketInterval = RegInit(UInt(16.W), 0.U)
    val rxAppendCrc = RegInit(Bool(), false.B)
    val rxHwmark = RegInit(UInt(5.W), 26.U)
    val rxLwmark = RegInit(UInt(5.W), 16.U)
    val crcCheckEn = RegInit(Bool(), false.B)
    val rxIfgSet = RegInit(UInt(6.W), 12.U)
    val rxMaxLength = RegInit(UInt(16.W), 1518.U)
    val rxMinLength = RegInit(UInt(7.W), 32.U)
    val cpuRdAddr = RegInit(UInt(6.W), 0.U)
    val cpuRdApply = RegInit(Bool(), false.B)
    val lineLoopEn = RegInit(Bool(), false.B)
    
    val srcMacHigh = RegInit(UInt(24.W), 0.U)
    val srcMacLow = RegInit(UInt(24.W), 0.U)
    val srcIp = RegInit(UInt(32.W), 0.U)
    val srcPort = RegInit(UInt(16.W), 0.U)
    val dstMacHigh = RegInit(UInt(24.W), 0.U)
    val dstMacLow = RegInit(UInt(24.W), 0.U)
    val dstIp = RegInit(UInt(32.W), 0.U)
    val dstPort = RegInit(UInt(16.W), 0.U)

    val ctrlStart = RegInit(Bool(), false.B)
    val ctrlStop = RegInit(Bool(), false.B)    
    val ctrlRst = RegInit(Bool(), false.B)
    
    val fields = Seq(
      RegField(5, fiAd, RegFieldDesc(name = "fiAd", desc = "MDIO PHY address")), // 0x00
      RegField(5, rgAd, RegFieldDesc(name = "rgAd", desc = "MDIO regiser address")), // 0x04
      RegField(16, ctrlData, RegFieldDesc(name = "ctrlData", desc = "MDIO data")), // 0x08
      RegField(1, writeCtrlData, RegFieldDesc(name = "writeCtrlData", desc = "Write MDIO data")), // 0x0C
      RegField(1, noPreamble, RegFieldDesc(name = "noPreamble", desc = "No MDIO preamble")), // 0x10
      RegField(8, divider, RegFieldDesc(name = "divider", desc = "MDIO clock divider")), // 0x14
      RegField(3, speed, RegFieldDesc(name = "speed", desc = "MAC Ethernet speed")), // 0x18
      RegField(1, fullDuplex, RegFieldDesc(name = "fullDuplex", desc = "Full duplex bus")), // 0x1C
      RegField(16, packetSize, RegFieldDesc(name = "fullDuplex", desc = "Full duplex bus")), // 0x20
      RegField(5, txHwmark, RegFieldDesc(name = "txHwmark", desc = "txHwmark")), // 0x24
      RegField(5, txLwmark, RegFieldDesc(name = "txLwmark", desc = "txLwmark")), // 0x28
      RegField(1, pauseFrameSendEn, RegFieldDesc(name = "pauseFrameSendEn", desc = "pauseFrameSendEn")), // 0x2C
      RegField(16, pauseQuantaSet, RegFieldDesc(name = "pauseQuantaSet", desc = "pauseQuantaSet")), // 0x30
      RegField(6, ifgSet, RegFieldDesc(name = "ifgSet", desc = "ifgSet")), // 0x34
      RegField(4, maxRetry, RegFieldDesc(name = "maxRetry", desc = "maxRetry")), // 0x38
      RegField(1, macTxAddEn, RegFieldDesc(name = "macTxAddEn", desc = "macTxAddEn")), // 0x3C
      RegField(8, macTxAddPromData, RegFieldDesc(name = "macTxAddPromData", desc = "macTxAddPromData")), // 0x40
      RegField(3, macTxAddPromAdd, RegFieldDesc(name = "macTxAddPromAdd", desc = "macTxAddPromAdd")), // 0x44
      RegField(1, macTxAddPromWr, RegFieldDesc(name = "macTxAddPromWr", desc = "macTxAddPromWr")), // 0x48
      RegField(1, txPauseEn, RegFieldDesc(name = "txPauseEn", desc = "txPauseEn")), // 0x4C
      RegField(1, xOffCpu, RegFieldDesc(name = "xOffCpu", desc = "xOffCpu")), // 0x50
      RegField(1, xOnCpu, RegFieldDesc(name = "xOnCpu", desc = "xOnCpu")), // 0x54
      RegField(1, macRxAddChkEn, RegFieldDesc(name = "macRxAddChkEn", desc = "macRxAddChkEn")), // 0x58
      RegField(8, macRxAddPromData, RegFieldDesc(name = "macRxAddPromData", desc = "macRxAddPromData")), // 0x5C
      RegField(3, macRxAddPromAdd, RegFieldDesc(name = "macRxAddPromAdd", desc = "macRxAddPromAdd")), // 0x60
      RegField(1, macRxAddPromWr, RegFieldDesc(name = "macRxAddPromWr", desc = "macRxAddPromWr")), // 0x64
      RegField(1, broadcastFilterEn, RegFieldDesc(name = "broadcastFilterEn", desc = "broadcastFilterEn")), // 0x68
      RegField(16, broadcastBucketDepth, RegFieldDesc(name = "brodcastBucketDepth", desc = "brodcastBucketDepth")), // 0x6C
      RegField(16, broadcastBucketInterval, RegFieldDesc(name = "brodcastBucketInterval", desc = "brodcastBucketInterval")), // 0x70
      RegField(1, rxAppendCrc, RegFieldDesc(name = "rxAppendCrc", desc = "rxAppendCrc")), // 0x74
      RegField(5, rxHwmark, RegFieldDesc(name = "rxHwmark", desc = "rxHwmark")), // 0x78
      RegField(5, rxLwmark, RegFieldDesc(name = "rxLwmark", desc = "rxLwmark")), // 0x7C
      RegField(1, crcCheckEn, RegFieldDesc(name = "crcCheckEn", desc = "crcCheckEn")), // 0x80
      RegField(6, rxIfgSet, RegFieldDesc(name = "rxIfgSet", desc = "rxIfgSet")), // 0x84
      RegField(16, rxMaxLength, RegFieldDesc(name = "rxMaxLength", desc = "rxMaxLength")), // 0x88
      RegField(7, rxMinLength, RegFieldDesc(name = "rxMinLength", desc = "rxMinLength")), // 0x8C
      RegField(6, cpuRdAddr, RegFieldDesc(name = "cpuRdAddr", desc = "cpuRdAddr")), // 0x90
      RegField(1, cpuRdApply, RegFieldDesc(name = "cpuRdApply", desc = "cpuRdApply")), // 0x94
      RegField(1, lineLoopEn, RegFieldDesc(name = "lineLoopEn", desc = "lineLoopEn")), // 0x98
      
      RegField(24, srcMacHigh, RegFieldDesc(name = "srcMacHigh", desc = "Source MAC address higher bytes")), // 0x9C
      RegField(24, srcMacLow, RegFieldDesc(name = "srcMacLow", desc = "Source MAC address lower bytes")), // 0xA0
      RegField(32, srcIp, RegFieldDesc(name = "srcIp", desc = "Source IP address")), // 0xA4
      RegField(16, srcPort, RegFieldDesc(name = "srcPort", desc = "Source port number")), // 0xA8
      RegField(24, dstMacHigh, RegFieldDesc(name = "dstMacHigh", desc = "Destination MAC address higher bytes")), // 0xAC
      RegField(24, dstMacLow, RegFieldDesc(name = "dstMacLow", desc = "Destination MAC address lower bytes")), // 0xB0
      RegField(32, dstIp, RegFieldDesc(name = "dstIp", desc = "Destination IP address")), // 0xB4
      RegField(16, dstPort, RegFieldDesc(name = "dstPort", desc = "Destination port number")), // 0xB8

      RegField(1, ctrlStart, RegFieldDesc(name = "ctrlStart", desc = "Control start TCP connection")), // 0xBC
      RegField(1, ctrlStop, RegFieldDesc(name = "ctrlStop", desc = "Control stop TCP connection")), // 0xC0      
      RegField(1, ctrlRst, RegFieldDesc(name = "ctrlRst", desc = "Control reset")) // 0xC4 
    )
    mem.get.regmap(fields.zipWithIndex.map({ case (f, i) => i * beatBytes -> Seq(f)}): _*)
    
    io.txHwmark := txHwmark
    io.txLwmark := txLwmark
    io.pauseFrameSendEn := pauseFrameSendEn
    io.pauseQuantaSet := pauseQuantaSet
    io.ifgSet := ifgSet
    io.fullDuplex := fullDuplex
    io.maxRetry := maxRetry
    io.macTxAddEn := macTxAddEn
    io.macTxAddPromData := macTxAddPromData
    io.macTxAddPromAdd := macTxAddPromAdd
    io.macTxAddPromWr := macTxAddPromWr
    io.txPauseEn := txPauseEn
    io.xOffCpu := xOffCpu
    io.xOnCpu := xOnCpu
    io.macRxAddChkEn := macRxAddChkEn
    io.macRxAddPromData := macRxAddPromData
    io.macRxAddPromAdd := macRxAddPromAdd
    io.macRxAddPromWr := macRxAddPromWr
    io.broadcastFilterEn := broadcastFilterEn
    io.broadcastBucketDepth := broadcastBucketDepth
    io.broadcastBucketInterval := broadcastBucketInterval
    io.rxAppendCrc := rxAppendCrc
    io.rxHwmark := rxHwmark
    io.rxLwmark := rxLwmark
    io.crcCheckEn := crcCheckEn
    io.rxIfgSet := rxIfgSet
    io.rxMaxLength := rxMaxLength
    io.rxMinLength := rxMinLength
    io.cpuRdAddr := cpuRdAddr
    io.cpuRdApply := cpuRdApply
    io.lineLoopEn := lineLoopEn
    io.speed := speed
    io.divider := divider
    io.ctrlData := ctrlData
    io.rgAd := rgAd
    io.fiAd := fiAd
    io.writeCtrlData := writeCtrlData
    io.noPreamble := noPreamble
    io.packetSize := packetSize
    
    io.srcMac := Cat(srcMacHigh, srcMacLow)
    io.srcIp := srcIp
    io.srcPort := srcPort
    io.dstMac := Cat(dstMacHigh, dstMacLow)
    io.dstIp := dstIp
    io.dstPort := dstPort

    io.ctrlStart := ctrlStart
    io.ctrlStop := ctrlStop    
    io.ctrlRst := ctrlRst
  }

}

class TemacConfigBlock (
  csrAddress: AddressSet,
  beatBytes: Int
) (implicit p: Parameters)
  extends TemacConfig(csrAddress, beatBytes) {
    
    def makeIO2(): TemacConfigIO = {
    val io2: TemacConfigIO = IO(io.cloneType)
    io2.suggestName("ioConfig")
    io2 <> io
    io2
  }
  
  val ioConfig = InModuleBody { makeIO2() }
  
  def standaloneParams = AXI4BundleParameters(addrBits = 32, dataBits = 32, idBits = 1)
    val ioMem = mem.map { m => {
      val ioMemNode = BundleBridgeSource(() => AXI4Bundle(standaloneParams))

      m :=
      BundleBridgeToAXI4(AXI4MasterPortParameters(Seq(AXI4MasterParameters("bundleBridgeToAXI4")))) :=
      ioMemNode

      val ioMem = InModuleBody { ioMemNode.makeIO() }
      ioMem
    }}
    
}

object TemacConfigBlockApp extends App
{

  implicit val p: Parameters = Parameters.empty
  val configModule = LazyModule(new TemacConfigBlock(AddressSet(0x20000000, 0xFF), 4) { // with AXI4Block {
    override def standaloneParams = AXI4BundleParameters(addrBits = 32, dataBits = 32, idBits = 1)
  })
  chisel3.Driver.execute(args, ()=> configModule.module)
}




