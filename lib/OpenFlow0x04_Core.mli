open Packet

type 'a mask = { m_value : 'a; m_mask : 'a option }

type xid = int32
type int12 = int16

type payload =
  | Buffered of int32 * bytes 
    (** [Buffered (id, buf)] is a packet buffered on a switch. *)
  | NotBuffered of bytes

val val_to_mask : 'a1 -> 'a1 mask

type switchId = int64

type groupId = int32

type portId = int32

type tableId = int8

type bufferId = int32

type oxm =
| OxmInPort of portId
| OxmInPhyPort of portId
| OxmMetadata of int64 mask
| OxmEthType of int16
| OxmEthDst of int48 mask
| OxmEthSrc of int48 mask
| OxmVlanVId of int12 mask
| OxmVlanPcp of int8
| OxmIPProto of int8
| OxmIPDscp of int8
| OxmIPEcn of int8
| OxmIP4Src of int32 mask
| OxmIP4Dst of int32 mask
| OxmTCPSrc of int16 mask
| OxmTCPDst of int16 mask
| OxmARPOp of int16
| OxmARPSpa of int32 mask
| OxmARPTpa of int32 mask
| OxmARPSha of int48 mask
| OxmARPTha of int48 mask
| OxmICMPType of int8
| OxmICMPCode of int8
| OxmMPLSLabel of int32
| OxmMPLSTc of int8
| OxmTunnelId of int64 mask

type oxmMatch = oxm list

val match_all : oxmMatch

type pseudoPort =
| PhysicalPort of portId
| InPort
| Flood
| AllPorts
| Controller of int16
| Any

type action =
| Output of pseudoPort
| Group of groupId
| PopVlan
| PushVlan
| PopMpls
| PushMpls
| SetField of oxm

type actionSequence = action list

type instruction =
| GotoTable of tableId
| ApplyActions of actionSequence
| WriteActions of actionSequence

type bucket = { bu_weight : int16; bu_watch_port : portId option;
                bu_watch_group : groupId option; bu_actions : actionSequence }

type groupType =
| All
| Select
| Indirect
| FF

type groupMod =
| AddGroup of groupType * groupId * bucket list
| DeleteGroup of groupType * groupId

type timeout =
| Permanent
| ExpiresAfter of int16

type flowModCommand =
| AddFlow
| ModFlow
| ModStrictFlow
| DeleteFlow
| DeleteStrictFlow

type flowModFlags = { fmf_send_flow_rem : bool; fmf_check_overlap : bool;
                      fmf_reset_counts : bool; fmf_no_pkt_counts : bool;
                      fmf_no_byt_counts : bool }

type flowMod = { mfCookie : int64 mask; mfTable_id : tableId;
                 mfCommand : flowModCommand; mfIdle_timeout : timeout;
                 mfHard_timeout : timeout; mfPriority : int16;
                 mfBuffer_id : bufferId option;
                 mfOut_port : pseudoPort option;
                 mfOut_group : groupId option; mfFlags : flowModFlags;
                 mfOfp_match : oxmMatch; mfInstructions : instruction list }

val add_flow : int16 -> oxmMatch -> instruction list -> flowMod

val delete_all_flows : flowMod

type packetInReason =
| NoMatch
| ExplicitSend

type packetIn = { pi_total_len : int16;
                  pi_reason : packetInReason; pi_table_id : tableId;
                  pi_cookie : int64; pi_ofp_match : oxmMatch;
                  pi_payload : payload }

type capabilities = { flow_stats : bool; table_stats : bool;
                      port_stats : bool; group_stats : bool; ip_reasm : 
                      bool; queue_stats : bool; port_blocked : bool }

type portState = { link_down : bool; blocked : bool; live : bool }

type portDesc = { port_no : portId; state : portState }

type portReason =
  | PortAdd
  | PortDelete
  | PortModify

type portStatus = { reason : portReason; desc : portDesc }

type packetOut = { po_in_port : pseudoPort;
                   po_actions : actionSequence; po_payload : payload }

type multipartRequest = 
  | SwitchDescReq
  | PortsDescReq 

type multipartReply = 
  | PortsDescReply of portDesc list
