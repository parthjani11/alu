module alu #(parameter WIDTH = 4)(
        input CLK, RST, MODE, CE, CIN,
        input [1:0] INP_VALID,
        input [3:0] CMD,
        input [WIDTH-1:0] OPA, OPB,
        output reg ERR, OFLOW, COUT, G, L, E,
        output reg [(2*WIDTH)-1:0] RES
        );

reg ERR_b, OFLOW_b, COUT_b, G_b, L_b, E_b;
reg [1:0]cnt;
reg [(2*WIDTH)-1:0] RES_b;
reg [(2*WIDTH)-1:0] RES_b2;
wire [(2*WIDTH)-1:0]add,sub;

assign add = $signed(OPA) + $signed(OPB);
assign sub = $signed(OPA) - $signed(OPB);

always@(posedge CLK or posedge RST)begin
    if(RST)begin
        ERR_b <= 1'b0;
        cnt <= 2'd0;
        OFLOW_b <= 1'b0; 
        COUT_b <= 1'b0; 
        G_b <= 1'b0;
        L_b <= 1'b0;
        E_b <= 1'b0;
        RES_b <= {(2*WIDTH){1'b0}};
    end
    else if(CE)begin
                ERR_b <= 1'b0;
                OFLOW_b <= 1'b0; 
                COUT_b <= 1'b0; 
                G_b <= 1'b0;
                L_b <= 1'b0;
                E_b <= 1'b0;
                RES_b <= {(2*WIDTH){1'b0}};
                
                if(MODE)begin  //ARITHEMATIC
                    case(INP_VALID)
                    2'b00: begin                 //Both invalid no operation possible
                            ERR_b <= 1'b1;  
                           end
                    2'b01: begin 
                            case(CMD)
                            4'd4: begin //INC A
                                    RES_b <= OPA + 1'b1;
                                  end
                             4'd5: begin //DEC A
                                    RES_b <= OPA - 1'b1;
                                   end
                             default:begin
                                         ERR_b <= 1'b1;
                                     end
                             endcase
                           end
                            
                    2'b10: begin 
                            case(CMD)
                            4'd6: begin //INC B
                                    RES_b <= OPB + 1'b1;
                                  end
                             4'd7: begin //DEC B
                                    RES_b <= OPB - 1'b1;
                                   end
                             default:begin
                                         ERR_b <= 1'b1;
                                     end
                             endcase
                           end
                     2'b11: begin
                                case(CMD)

                                4'd0: begin    //ADD
                                        RES_b <= OPA + OPB;
                                        if((OPA + OPB) > {WIDTH{1'b1}}) COUT_b <= 1'b1;
                                        else COUT_b <= 1'b0;
                                      end
                                4'd1: begin    //SUB
                                        RES_b <= OPA - OPB;   
                                      end
                                4'd2: begin   //ADD_CIN
                                        RES_b <= OPA + OPB + CIN;
                                        if((OPA + OPB + CIN) > {WIDTH{1'b1}}) COUT_b <= 1'b1;
                                        else COUT_b <= 1'b0;
                                      end 
                                4'd3: begin   // SUB_CIN
                                        RES_b <= OPA - OPB - CIN;
                                        OFLOW_b <= (OPA < (OPB + CIN));
                                      end
                                4'd4: begin //INC A
                                    RES_b <= OPA + 1'b1;
                                  end
                                4'd5: begin //DEC A
                                    RES_b <= OPA - 1'b1;
                                  end
                                4'd6: begin //INC B
                                    RES_b <= OPB + 1'b1;
                                  end
                                4'd7: begin //DEC B
                                    RES_b <= OPB - 1'b1;
                                   end
                                4'd8: begin
                                        if(OPA > OPB)
                                            G_b <= 1'b1;
                                        else if(OPA < OPB)
                                            L_b <= 1'b1;
                                        else if(OPA == OPB)
                                            E_b <= 1'b1;
                                        else begin
                                            G_b <= 1'b0;
                                            L_b <= 1'b0;
                                            E_b <= 1'b0;
                                            end
                                      end
                                4'd9: begin  //MUL ADD RES_b2 
                                        
                                        if(cnt==0) begin
                                            RES_b <= {(2*WIDTH){1'b0}};
                                            cnt <= cnt + 1'b1;
                                        end
                                        else if(cnt==1) begin
                                                RES_b <= ((OPA + 1'b1)*(OPB + 1'b1));
                                                cnt <= cnt + 1'b1;
                                        end
                                        else if(cnt==2) begin
                                                cnt <= 2'd0;
                                        end
                                      end
                                4'd10: begin
                                        if(cnt==0) begin
                                            RES_b <= {(2*WIDTH){1'b0}};
                                            cnt <= cnt + 1'b1;
                                        end
                                        else if(cnt==1) begin
                                                RES_b <= ((OPA << 1)*OPB);
                                                cnt <= cnt + 1'b1;
                                        end
                                        else if(cnt==2) begin
                                                cnt <= 2'd0;
                                        end
                                      end

                                4'd11: begin //signed ADD
                                        RES_b <= $signed(OPA) + $signed(OPB);
                                        OFLOW_b <= ((OPA[WIDTH-1] == OPB[WIDTH-1]) && (OPA[WIDTH-1] != add[WIDTH-1]));
                                        end
                                4'd12: begin //signed SUB
                                        RES_b <= $signed(OPA) - $signed(OPB);
                                        OFLOW_b <= ((OPA[WIDTH-1] != OPB[WIDTH-1]) && (OPA[WIDTH-1] != sub[WIDTH-1]));
                                        end
                                default: ERR_b <= 1'b1;
                                endcase
                            end
                     default: ERR_b <= 1'b1;        
                     endcase
                     end
                else begin  //LOGICAL
                    case(INP_VALID)
                    2'b00: begin                 //Both invalid no operation possible
                            ERR_b <= 1'b1;  
                           end
                    2'b01: begin //VALID A
                            case(CMD)
                            4'd6: RES_b <= ~OPA; //NOT A
                            4'd8: RES_b <= (OPA >> 1); //SHR1 A
                            4'd9: RES_b <= (OPA << 1);  //SHL1 A
                            default: ERR_b <= 1'b1;
                            endcase
                           end
                    2'b10: begin //VALID B
                            case(CMD)
                            4'd7: RES_b <= ~OPB; //NOT B
                            4'd10: RES_b <= (OPB >> 1); //SHR1 B
                            4'd11: RES_b <= (OPB << 1);  //SHL1 B
                            default: ERR_b <= 1'b1;
                            endcase
                           end
                    2'b11: begin //VALID Both
                            case(CMD)
                            4'd0: RES_b <= OPA & OPB;
                            4'd1: RES_b <= ~(OPA & OPB);
                            4'd2: RES_b <= OPA | OPB;
                            4'd3: RES_b <= ~(OPA | OPB);
                            4'd4: RES_b <= OPA ^ OPB;
                            4'd5: RES_b <= ~(OPA ^ OPB);
                            4'd6: RES_b <= ~OPA; //NOT A
                            4'd8: RES_b <= (OPA >> 1); //SHR1 A
                            4'd9: RES_b <= (OPA << 1);  //SHL1 A
                            4'd7: RES_b <= ~OPB; //NOT B
                            4'd10: RES_b <= (OPB >> 1); //SHR1 B
                            4'd11: RES_b <= (OPB << 1);  //SHL1 B
                            4'd12: begin
                                        if(|OPB[WIDTH-1:$clog2(WIDTH)])
                                            ERR_b <= 1'b1;
                                        else
                                            RES_b <= (OPA << OPB[$clog2(WIDTH)-1:0]) |
                                                     (OPA >> (WIDTH - OPB[$clog2(WIDTH)-1:0]));
                                   end
                            4'd13: begin
                                    if(|OPB[WIDTH-1:$clog2(WIDTH)])
                                        ERR_b <= 1'b1;
                                    else
                                        RES_b <= (OPA >> OPB[$clog2(WIDTH) - 1:0]) | (OPA << (WIDTH - OPB[$clog2(WIDTH) - 1:0])) ;
                                    end

                            default: ERR_b <= 1'b1;
                            endcase
                            end
                    endcase
                    end
         end
end


    
always@(posedge CLK or posedge RST)begin

if(RST)begin
ERR <= 1'b0; 
OFLOW <= 1'b0;                            
COUT  <= 1'b0;                            
G <= 1'b0;                       
L <= 1'b0;                                  
E <= 1'b0;                                          
RES <= {(2*WIDTH){1'b0}};
end
else begin
ERR <= ERR_b; 
OFLOW <= OFLOW_b;                            
COUT  <= COUT_b;                            
G <= G_b;                       
L <= L_b;                                   
E <= E_b;                                   
RES <= RES_b;

end
end                                                                             
endmodule