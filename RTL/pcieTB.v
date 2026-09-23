
//GQ//module pcieTB;
//GQ//    parameter MAXPIPEWIDTH = 32;
//GQ//	parameter DEVICETYPE = 0; //0 for downstream 1 for upstream
//GQ//	parameter LANESNUMBER =16;
//GQ//	parameter GEN1_PIPEWIDTH = 8 ;	
//GQ//	parameter GEN2_PIPEWIDTH = 8 ;	
//GQ//	parameter GEN3_PIPEWIDTH = 8 ;								
//GQ//	parameter GEN4_PIPEWIDTH = 8 ;	
//GQ//	parameter GEN5_PIPEWIDTH = 8 ;	
//GQ//	parameter MAX_GEN = 1;
//GQ//reg CLK;
//GQ//reg reset;
//GQ////output phy_reset,
//GQ////PIPE interface width
//GQ////output [1:0] width, ///////////////////which module
//GQ////TX_signals
//GQ//wire [1:0] width;
//GQ//wire [MAXPIPEWIDTH*LANESNUMBER-1:0]TxData;
//GQ//wire [LANESNUMBER-1:0]TxDataValid;
//GQ//wire [LANESNUMBER-1:0]TxElecIdle;
//GQ//wire [LANESNUMBER-1:0]TxStartBlock;
//GQ//wire [(MAXPIPEWIDTH/8)*LANESNUMBER-1:0]TxDataK;
//GQ//wire [2*LANESNUMBER -1:0]TxSyncHeader;
//GQ//wire [LANESNUMBER-1:0]TxDetectRx_Loopback;
//GQ////RX_signals
//GQ//wire [MAXPIPEWIDTH*LANESNUMBER-1:0]RxData;
//GQ//wire [LANESNUMBER-1:0]RxDataValid;////////////////////////////////////////
//GQ//wire[(MAXPIPEWIDTH/8)*LANESNUMBER-1:0]RxDataK;
//GQ//wire[LANESNUMBER-1:0]RxStartBlock;
//GQ//wire[2*LANESNUMBER -1:0]RxSyncHeader;
//GQ//wire[LANESNUMBER-1:0]RxValid;
//GQ//wire [15:0]RxStandby;
//GQ//reg	[3*LANESNUMBER -1:0]RxStatus;
//GQ//reg [15:0]RxElectricalIdle;
//GQ////commands and status signals
//GQ//wire [4*LANESNUMBER-1:0]PowerDown;
//GQ//wire  [3:0]Rate;
//GQ//reg [LANESNUMBER-1:0]PhyStatus;
//GQ//
//GQ////pclkcontrolsignal
//GQ//wire [4:0]PCLKRate;
//GQ//wire PclkChangeAck;
//GQ//reg  PclkChangeOk;
//GQ////eq_signals
//GQ//reg 	[18*LANESNUMBER -1:0]LocalTxPresetCoefficients;
//GQ//wire 	[18*LANESNUMBER -1:0]TxDeemph;
//GQ//reg 	[6*LANESNUMBER -1:0]LocalFS;
//GQ//reg 	[6*LANESNUMBER -1:0]LocalLF;
//GQ//wire 	[4*LANESNUMBER -1:0]LocalPresetIndex;
//GQ//wire 	[LANESNUMBER -1:0]GetLocalPresetCoeffcients;
//GQ//reg 	[LANESNUMBER -1:0]LocalTxCoefficientsValid;
//GQ//wire 	[6*LANESNUMBER -1:0]LF;
//GQ//wire 	[6*LANESNUMBER -1:0]FS;
//GQ//wire 	[LANESNUMBER -1:0]RxEqEval;
//GQ//wire 	[LANESNUMBER -1:0]InvalidRequest;
//GQ//reg 	[6*LANESNUMBER -1:0]LinkEvaluationFeedbackDirectionChange;
//GQ//wire    pl_trdy;
//GQ//reg     lp_irdy;
//GQ//reg     [512-1:0]lp_data;
//GQ//reg     [64-1:0]lp_valid;
//GQ//wire [512-1:0]pl_data;
//GQ//wire [64-1:0] pl_valid;
//GQ//reg  [3:0]lp_state_req;
//GQ//wire [3:0]pl_state_sts;
//GQ//wire [2:0]pl_speedmode;////////////////////////////////////////
//GQ//reg lp_force_detect;
//GQ//////lPIF start & end of TLP DLLP
//GQ//reg [64-1:0]lp_dlpstart;
//GQ//reg [64-1:0]lp_dlpend;
//GQ//reg  [64-1:0]lp_tlpstart;
//GQ//reg  [64-1:0]lp_tlpend;
//GQ//wire [64-1:0]pl_dlpstart;
//GQ//wire [64-1:0]pl_dlpend;
//GQ//wire [64-1:0]pl_tlpstart;
//GQ//wire [64-1:0]pl_tlpend;
//GQ//wire [64-1:0]pl_tlpedb;
//GQ//wire pl_linkUp;
//GQ////optional Message bus
//GQ//wire [7:0] M2P_MessageBus;
//GQ//reg  [7:0] P2M_MessageBus;
//GQ//
//GQ//localparam[1:0]
//GQ//        reset_   = 2'd0,
//GQ//        active_  = 2'd1,
//GQ//        retrain_ = 2'd2;
//GQ//integer i;
//GQ//
//GQ//initial
//GQ//begin
//GQ//    CLK = 0;
//GQ//    reset = 0;
//GQ//    #20
//GQ//    reset = 1;
//GQ//    #10
//GQ//    lp_state_req = reset_;
//GQ//    #10
//GQ//    wait(TxDetectRx_Loopback);
//GQ//    #10
//GQ//    PhyStatus={16{1'b1}};
//GQ//    RxStatus={16{3'b011}};
//GQ//    #10
//GQ//    RxStatus=16'd0;
//GQ//    lp_state_req = active_;
//GQ//    //wait(pl_state_sts == 3)
//GQ//    //lp_state_req = retrain_;
//GQ//    wait(GetLocalPresetCoeffcients == {16{1'b1}});
//GQ//    LocalTxCoefficientsValid = {16{1'b1}};
//GQ//    LocalTxPresetCoefficients={16*18{1'b1}};
//GQ//    LocalLF={16*6{1'b1}};
//GQ//    LocalFS={16*6{1'b1}};
//GQ//	wait(pl_linkUp && pl_speedmode==3'd4 && pl_state_sts==active_);
//GQ//	lp_state_req = active_;
//GQ//	@(negedge CLK);
//GQ//	lp_irdy=1;
//GQ//	for (i=0;i<512;i=i+1) 
//GQ//	begin
//GQ//		lp_data[i]=$random;
//GQ//		lp_tlpstart[i]=0;
//GQ//		lp_tlpend[i]=0;
//GQ//		lp_dlpend[i]=0;
//GQ//		lp_dlpstart[i]=0;
//GQ//	end
//GQ//	lp_valid={2'b00, {62{1'b1}}};
//GQ//	lp_tlpstart[0]=1;
//GQ//	lp_tlpend[61]=1;
//GQ//    // lp_dlpstart[0]=1;
//GQ//    // lp_dlpend[5]=1;
//GQ//	#10
//GQ//	lp_irdy=0;
//GQ//end
//GQ//always #5 CLK = ~CLK;
//GQ//
//GQ//
//GQ//
//GQ//
//GQ//PCIe #(
//GQ//	
//GQ//	.MAXPIPEWIDTH(32),
//GQ//	.DEVICETYPE (0), //0 for downstream 1 for upstream
//GQ//	. LANESNUMBER (16),
//GQ//	. GEN1_PIPEWIDTH (8) ,	
//GQ//	. GEN2_PIPEWIDTH (8) ,	
//GQ//	. GEN3_PIPEWIDTH (8) ,								
//GQ//	. GEN4_PIPEWIDTH (8) ,	
//GQ//	. GEN5_PIPEWIDTH (8) ,	
//GQ//	. MAX_GEN (5)
//GQ//)
//GQ//pcie
//GQ//(
//GQ////clk and reset 
//GQ// CLK,
//GQ// reset,
//GQ// phy_reset,
//GQ////PIPE interface width
//GQ// width, ///////////////////which module
//GQ////TX_signals
//GQ// TxData,
//GQ// TxDataValid,
//GQ// TxElecIdle,
//GQ// TxStartBlock,
//GQ// TxDataK,
//GQ// TxSyncHeader,
//GQ// TxDetectRx_Loopback,
//GQ////RX_signals
//GQ// RxData,
//GQ// RxDataValid,////////////////////////////////////////
//GQ// RxDataK,
//GQ// RxStartBlock,
//GQ// RxSyncHeader,
//GQ// RxStatus,
//GQ// RxElectricalIdle,
//GQ////commands and status signals
//GQ// PowerDown,
//GQ// Rate,
//GQ// PhyStatus,
//GQ//
//GQ////pclkcontrolsignal
//GQ// PCLKRate,
//GQ// PclkChangeAck,
//GQ// PclkChangeOk,
//GQ////eq_signals
//GQ// LocalTxPresetCoefficients,
//GQ// TxDeemph,
//GQ// LocalFS,
//GQ// LocalLF,
//GQ// LocalPresetIndex,
//GQ// GetLocalPresetCoeffcients,
//GQ// LocalTxCoefficientsValid,
//GQ//LF,
//GQ//FS,
//GQ//RxEqEval,
//GQ//InvalidRequest,
//GQ//LinkEvaluationFeedbackDirectionChange,
//GQ//pl_trdy,
//GQ//lp_irdy,
//GQ//lp_data,
//GQ//lp_valid,
//GQ//pl_data,
//GQ//pl_valid,
//GQ//lp_state_req,
//GQ//pl_state_sts,
//GQ//pl_speedmode,////////////////////////////////////////
//GQ//lp_force_detect,
//GQ//////lPIF start & end of TLP DLLP
//GQ//lp_dlpstart,
//GQ//lp_dlpend,
//GQ//lp_tlpstart,
//GQ//lp_tlpend,
//GQ//pl_dlpstart,
//GQ//pl_dlpend,
//GQ//pl_tlpstart,
//GQ//pl_tlpend,
//GQ//pl_tlpedb,
//GQ//pl_linkUp,
//GQ////optional Message bus
//GQ//M2P_MessageBus,
//GQ//P2M_MessageBus,
//GQ//RxStandby
//GQ//);
//GQ//assign {RxData,RxDataValid,RxDataK,RxValid,RxSyncHeader,RxStartBlock} = {TxData,TxDataValid,TxDataK,TxDataValid,TxSyncHeader,TxStartBlock}; 
//GQ//endmodule
