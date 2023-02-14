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


class GbEMAC extends BlackBox {
    val io = IO(new Bundle {
        val clk = Input(Clock())
        val clk125 = Input(Clock())
        val clk125_90 = Input(Clock())
        val clk5 = Input(Clock())
        val reset = Input(Bool())
        
        val tx_streaming_data = Input(UInt(32.W))
        val tx_streaming_valid = Input(Bool())
        val tx_streaming_last = Input(Bool())
        val tx_streaming_ready = Output(Bool())
        
        val rx_streaming_data = Output(UInt(32.W))
        val rx_streaming_valid = Output(Bool())
        val rx_streaming_last = Output(Bool())
        val rx_streaming_ready = Input(Bool())
        
        val phy_resetn = Output(Bool())
        val rgmii_txd = Output(UInt(4.W))
        val rgmii_tx_ctl = Output(Bool())
        val rgmii_txc = Output(Bool())
        val rgmii_rxd = Input(UInt(4.W))
        val rgmii_rx_ctl = Input(Bool())
        val rgmii_rxc = Input(Bool())
        //val mdio = Input(Bool())
        val mdio = Analog(1.W)
        val mdc = Output(Bool())
        
        //val start_tcp = Input(Bool())
        //val fin_gen = Input(Bool())
        
        val txHwmark = Input(UInt(5.W))
        val txLwmark = Input(UInt(5.W))
        val pauseFrameSendEn = Input(Bool())
        val pauseQuantaSet = Input(UInt(16.W))
        val macTxAddEn = Input(Bool())
        val fullDuplex = Input(Bool())
        val maxRetry = Input(UInt(4.W))
        val ifgSet = Input(UInt(6.W))
        val macTxAddPromData = Input(UInt(8.W))
        val macTxAddPromAdd = Input(UInt(3.W))
        val macTxAddPromWr = Input(Bool())
        val txPauseEn = Input(Bool())
        val xOffCpu = Input(Bool())
        val xOnCpu = Input(Bool())
        val macRxAddChkEn = Input(Bool())
        val macRxAddPromData = Input(UInt(8.W))
        val macRxAddPromAdd = Input(UInt(3.W))
        val macRxAddPromWr = Input(Bool())
        val broadcastFilterEn = Input(Bool())
        val broadcastBucketDepth = Input(UInt(16.W))
        val broadcastBucketInterval = Input(UInt(16.W))
        val rxAppendCrc = Input(Bool())
        val rxHwmark = Input(UInt(5.W))
        val rxLwmark = Input(UInt(5.W))
        val crcCheckEn = Input(Bool())
        val rxIfgSet = Input(UInt(6.W))
        val rxMaxLength = Input(UInt(16.W))
        val rxMinLength = Input(UInt(7.W))
        val cpuRdAddr = Input(UInt(6.W))
        val cpuRdApply = Input(Bool())
        val lineLoopEn = Input(Bool())
        val speed = Input(UInt(3.W))
        val divider = Input(UInt(8.W))
        val ctrlData = Input(UInt(16.W))
        val rgAd = Input(UInt(5.W))
        val fiAd = Input(UInt(5.W))
        val writeCtrlData= Input(Bool())
        val noPreamble = Input(Bool())
        val packetSize = Input(UInt(16.W))
        val srcMac = Input(UInt(48.W))
        val srcIp = Input(UInt(32.W))
        val srcPort = Input(UInt(16.W))
        val dstMac = Input(UInt(48.W))
        val dstIp = Input(UInt(32.W))
        val dstPort = Input(UInt(16.W))
    })
}


class GbemacWrapperIO () extends Bundle {
    val clk125 = Input(Clock())
    val clk125_90 = Input(Clock())
    val clk5 = Input(Clock())
    val phy_resetn = Output(Bool())
    val rgmii_txd = Output(UInt(4.W))
    val rgmii_tx_ctl = Output(Bool())
    val rgmii_txc = Output(Bool())
    val rgmii_rxd = Input(UInt(4.W))
    val rgmii_rx_ctl = Input(Bool())
    val rgmii_rxc = Input(Bool())
    //val mdio = Input(Bool())
    val mdio = Analog(1.W)
    val mdc = Output(Bool())
}


class GbemacWrapper (csrAddressGbemac: AddressSet, beatBytes: Int) extends LazyModule()(Parameters.empty){ //[T <: Data : Real: BinaryRepresentation] 

  //lazy val io = Wire(new GbemacWrapperIO)
  
  val configBlock = LazyModule(new TemacConfig(csrAddressGbemac, beatBytes){
    def makeIO2(): TemacConfigIO = {
      val io2: TemacConfigIO = IO(io.cloneType)
      io2.suggestName("ioReg")
      io2 <> io
      io2
    }
    val ioReg = InModuleBody { makeIO2() }
  })
  
  //val mem = Some(AXI4RegisterNode(address = csrAddress, beatBytes = beatBytes))
  //val mem = Some(AXI4RegisterNode(address = csrAddressGbemac, beatBytes = beatBytes))
  val mem = Some(AXI4IdentityNode())
  
  val slaveNode = Some(AXI4StreamSlaveNode(AXI4StreamSlaveParameters()))
  val masterNode = Some(AXI4StreamMasterNode(Seq(AXI4StreamMasterPortParameters(Seq(AXI4StreamMasterParameters("masterNode", n = beatBytes))))))
  
  //mem.get := configBlock.mem.get
  configBlock.mem.get := mem.get
  
  lazy val module = new LazyModuleImp(this) {
    
    val io = IO(new GbemacWrapperIO)
    
    val gbemac = Module(new GbEMAC())
    
    gbemac.io.clk := clock
    gbemac.io.clk125 := io.clk125
    gbemac.io.clk125_90 := io.clk125_90
    gbemac.io.clk5 := io.clk5
    //gbemac.io.reset := configBlock.ioReg.ctrlRst
    gbemac.io.reset := reset
    
    io.phy_resetn := gbemac.io.phy_resetn
    io.rgmii_txd := gbemac.io.rgmii_txd
    io.rgmii_tx_ctl := gbemac.io.rgmii_tx_ctl
    io.rgmii_txc := gbemac.io.rgmii_txc
    gbemac.io.rgmii_rxd := io.rgmii_rxd
    gbemac.io.rgmii_rx_ctl := io.rgmii_rx_ctl
    gbemac.io.rgmii_rxc := io.rgmii_rxc
    //gbemac.io.mdio := io.mdio
    gbemac.io.mdio <> io.mdio
    io.mdc := gbemac.io.mdc
    
    gbemac.io.tx_streaming_data := slaveNode.get.in(0)._1.bits.data
    gbemac.io.tx_streaming_valid := slaveNode.get.in(0)._1.valid
    gbemac.io.tx_streaming_last := slaveNode.get.in(0)._1.bits.last
    slaveNode.get.in(0)._1.ready := gbemac.io.tx_streaming_ready
    
    masterNode.get.out(0)._1.bits.data := gbemac.io.rx_streaming_data
    masterNode.get.out(0)._1.valid := gbemac.io.rx_streaming_valid
    masterNode.get.out(0)._1.bits.last := gbemac.io.rx_streaming_last
    gbemac.io.rx_streaming_ready := masterNode.get.out(0)._1.ready
    
    //gbemac.io.start_tcp := configBlock.ioReg.ctrlStart
    //gbemac.io.fin_gen := configBlock.ioReg.ctrlStop
    gbemac.io.txHwmark := configBlock.ioReg.txHwmark
    gbemac.io.txLwmark := configBlock.ioReg.txLwmark
    gbemac.io.pauseFrameSendEn := configBlock.ioReg.pauseFrameSendEn
    gbemac.io.pauseQuantaSet := configBlock.ioReg.pauseQuantaSet
    gbemac.io.ifgSet := configBlock.ioReg.ifgSet
    gbemac.io.fullDuplex := configBlock.ioReg.fullDuplex
    gbemac.io.maxRetry := configBlock.ioReg.maxRetry
    gbemac.io.macTxAddEn := configBlock.ioReg.macTxAddEn
    gbemac.io.macTxAddPromData := configBlock.ioReg.macTxAddPromData
    gbemac.io.macTxAddPromAdd := configBlock.ioReg.macTxAddPromAdd
    gbemac.io.macTxAddPromWr := configBlock.ioReg.macTxAddPromWr
    gbemac.io.txPauseEn := configBlock.ioReg.txPauseEn
    gbemac.io.xOffCpu := configBlock.ioReg.xOffCpu
    gbemac.io.xOnCpu := configBlock.ioReg.xOnCpu
    gbemac.io.macRxAddChkEn := configBlock.ioReg.macRxAddChkEn
    gbemac.io.macRxAddPromData := configBlock.ioReg.macRxAddPromData
    gbemac.io.macRxAddPromAdd := configBlock.ioReg.macRxAddPromAdd
    gbemac.io.macRxAddPromWr := configBlock.ioReg.macRxAddPromWr
    gbemac.io.broadcastFilterEn := configBlock.ioReg.broadcastFilterEn
    gbemac.io.broadcastBucketDepth := configBlock.ioReg.broadcastBucketDepth
    gbemac.io.broadcastBucketInterval := configBlock.ioReg.broadcastBucketInterval
    gbemac.io.rxAppendCrc := configBlock.ioReg.rxAppendCrc
    gbemac.io.rxHwmark := configBlock.ioReg.rxHwmark
    gbemac.io.rxLwmark := configBlock.ioReg.rxLwmark
    gbemac.io.crcCheckEn := configBlock.ioReg.crcCheckEn
    gbemac.io.rxIfgSet := configBlock.ioReg.rxIfgSet
    gbemac.io.rxMaxLength := configBlock.ioReg.rxMaxLength
    gbemac.io.rxMinLength := configBlock.ioReg.rxMinLength
    gbemac.io.cpuRdAddr := configBlock.ioReg.cpuRdAddr
    gbemac.io.cpuRdApply := configBlock.ioReg.cpuRdApply
    gbemac.io.lineLoopEn := configBlock.ioReg.lineLoopEn
    gbemac.io.speed := configBlock.ioReg.speed
    gbemac.io.divider := configBlock.ioReg.divider
    gbemac.io.ctrlData := configBlock.ioReg.ctrlData
    gbemac.io.rgAd := configBlock.ioReg.rgAd
    gbemac.io.fiAd := configBlock.ioReg.fiAd
    gbemac.io.writeCtrlData := configBlock.ioReg.writeCtrlData
    gbemac.io.noPreamble := configBlock.ioReg.noPreamble
    gbemac.io.packetSize := configBlock.ioReg.packetSize
    gbemac.io.srcMac := configBlock.ioReg.srcMac
    gbemac.io.srcIp := configBlock.ioReg.srcIp
    gbemac.io.srcPort := configBlock.ioReg.srcPort
    gbemac.io.dstMac := configBlock.ioReg.dstMac
    gbemac.io.dstIp := configBlock.ioReg.dstIp
    gbemac.io.dstPort := configBlock.ioReg.dstPort
  }
  
}


class GbemacWrapperBlock (
  csrAddress: AddressSet,
  beatBytes: Int
) (implicit p: Parameters)
  extends GbemacWrapper(csrAddress, beatBytes) {
    
//     def makeIO2(): GbemacWrapperIO = {
//     val io2: GbemacWrapperIO = IO(io.cloneType)
//     io2.suggestName("ioGbemac")
//     io2 <> io
//     io2
//   }
//  
//  val ioGbemac = InModuleBody { makeIO2() }
  
  def standaloneParams = AXI4BundleParameters(addrBits = 32, dataBits = 32, idBits = 1)
    val ioMem = mem.map { m => {
      val ioMemNode = BundleBridgeSource(() => AXI4Bundle(standaloneParams))

      m :=
      BundleBridgeToAXI4(AXI4MasterPortParameters(Seq(AXI4MasterParameters("bundleBridgeToAXI4")))) :=
      ioMemNode

      val ioMem = InModuleBody { ioMemNode.makeIO() }
      ioMem
    }}
    
    val ioInNode = BundleBridgeSource(() => new AXI4StreamBundle(AXI4StreamBundleParameters(n = 4)))
    slaveNode.get := BundleBridgeToAXI4Stream(AXI4StreamMasterParameters(n = 4)) := ioInNode
    val in = InModuleBody { ioInNode.makeIO() }
    
    val ioOutNode = BundleBridgeSink[AXI4StreamBundle]()
    ioOutNode := AXI4StreamToBundleBridge(AXI4StreamSlaveParameters()) := masterNode.get
    val out = InModuleBody { ioOutNode.makeIO() }
    
}

object GbemacWrapperBlockApp extends App
{

  implicit val p: Parameters = Parameters.empty
  val gbemacModule = LazyModule(new GbemacWrapperBlock(AddressSet(0x20000000, 0xFF), 4) { // with AXI4Block {
    override def standaloneParams = AXI4BundleParameters(addrBits = 32, dataBits = 32, idBits = 1)
  })
  chisel3.Driver.execute(Array("--target-dir", "verilog/GbemacWrapper"), ()=> gbemacModule.module)
}


