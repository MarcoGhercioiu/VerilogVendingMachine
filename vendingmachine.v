/*
File: program3_mjg170001.v
Author: Marco Ghercioiu, MJG170001
Modules:
    DFF                     - A clock triggered memory storage module
    VendingMachine          - A module that passes signals from test bench to control module
    VendingMachineControl   - A module that implements vending machine logic and bank storage
*/

`timescale 1ns / 1ns

/*
Module: DFF
            - assigns out to in on clock 
Author: Marco Ghercioiu
Ports:
    clk     - I/P       input       A measurement to control execution
    in      - I/P       input       Wire containing value to assign to out
    out     - O/P       output      Register that is being changed on clock
*/

module DFF(clk, in, out);
    // define input wires
    input clk;
    input [15:0] in;
    // define output register
    output [15:0] out;
    reg [15:0] out;

    // on clock change assign out to in
    always @(clk)
        out = in;
endmodule

/*
Module: VendingMachine
            - A module that passes signals from test bench to control module
Author: Marco Ghercioiu
Ports:
    clk         - I/P       input       A measurement to control execution
    nickel      - I/P       input       signal that nickel is inserted
    dime        - I/P       input       signal that dime is inserted
    quarter     - I/P       input       signal that quarter is inserted
    half        - I/P       input       signal that half is inserted
    one         - I/P       input       signal that one is inserted
    two         - I/P       input       signal that two is inserted
    five        - I/P       input       signal that five is inserted
    ten         - I/P       input       signal that ten is inserted
    twenty      - I/P       input       signal that twenty is inserted

    currCommand - I/P       input       Wire carrying the users command

    deposit     - I/P       input       deposit command signal
    select      - I/P       input       select command signal
    cancel      - I/P       input       cancel command signal
    valid       - I/P       input       valid command signal
*/

module VendingMachine(clk, nickel, dime, quarter, half, one, two, five, ten, twenty, currCommand, deposit, select, cancel, valid);
    // define wires for currecny input signals
    input clk, nickel, dime, quarter, half, one, two, five, ten, twenty, dispense, done;
    input deposit, select, cancel, valid;

    // current command from commands.txt
    input [15:0] currCommand;
    // user balance wire
    output [15:0] balance;
    // create vending machine control
    VendingMachineControl vmc(clk, nickel, dime, quarter, half, one, two, five, ten, twenty,
    deposit, select, cancel, balance, valid, currCommand);

endmodule

/*
Module: VendingMachineControl
            - A module that implements vending machine logic and bank storage
Author: Marco Ghercioiu
Ports:
    clk         - I/P       input       A measurement to control execution
    nickel      - I/P       input       signal that nickel is inserted
    dime        - I/P       input       signal that dime is inserted
    quarter     - I/P       input       signal that quarter is inserted
    half        - I/P       input       signal that half is inserted
    one         - I/P       input       signal that one is inserted
    two         - I/P       input       signal that two is inserted
    five        - I/P       input       signal that five is inserted
    ten         - I/P       input       signal that ten is inserted
    twenty      - I/P       input       signal that twenty is inserted

    balance     - O/P       output      user bank total  
   
    deposit     - I/P       input       deposit command signal
    select      - I/P       input       select command signal
    cancel      - I/P       input       cancel command signal
    valid       - I/P       input       valid command signal

    currCommand - I/P       input       Wire carrying the users command
*/

module VendingMachineControl (clk, nickel, dime, quarter, half, one, two, five, ten, twenty,
    deposit, select, cancel, balance, valid, currCommand);
    // define wires for currecny input signals
    input clk, nickel, dime, quarter, half, one, two, five, ten, twenty, done, enough, zero, deposit, select, cancel, valid;
    // user balance wire
    output [15:0] balance;
    // price of item selected
    reg [15:0] purchase;
    // item selected
    reg [11:0] choice;
    // price.txt storage
    reg [11:0] price[0:71];
    // current command
    input [15:0] currCommand;
    // counter for user balance
    reg [15:0] total;
    // user currency type counter
    reg [35:0] userBank;
    // for loop variable
    integer i;
    // assign output wire balance to user total balance counter
    DFF a(clk, total, balance);

    // define constants
    parameter coin0 = 11'b100000000, coin1 = 11'b010000000, coin2 = 11'b001000000, coin3 = 11'b000100000, coin4 = 11'b000010000, coin5 = 11'b000001000,
                coin6 = 11'b000000100, coin7 = 11'b000000010, coin8 = 11'b000000001;

    // define bank currency counters
    reg [7:0] ni;reg [7:0] di;reg [7:0] qu;reg [7:0] ha;reg [7:0] on;reg [7:0] to;reg [7:0] fi;reg [7:0] te;reg [7:0] tw;
    // initialize state of bank
    initial begin : initialization
        $readmemh("price.txt", price);
        i = 0;
        userBank = 36'd0; total = 11'd0;ni = 8'd0;di = 8'd0;qu = 8'd0;ha = 8'd0;on = 8'd0;to = 8'd0;fi = 8'd0;te = 8'd0;tw = 8'd0;
    end

    always @(posedge clk) begin                                         // execute on clock edge
        case({valid,nickel,dime,quarter,half,one,two,five,ten,twenty})  // one-hot currency switch
            // increment bank based on currency inserted
            10'b1100000000 : ni = ni + 1; 
            10'b1010000000 : di = di + 1; 
            10'b1001000000 : qu = qu + 1; 
            10'b1000100000 : ha = ha + 1; 
            10'b1000010000 : on = on + 1; 
            10'b1000001000 : to = to + 1; 
            10'b1000000100 : fi = fi + 1; 
            10'b1000000010 : te = te + 1; 
            10'b1000000001 : tw = tw + 1; 
        endcase
        
        // if state is deposit
        if(deposit)begin
        case({nickel,dime,quarter,half,one,two,five,ten,twenty}) // check currency inserted when deposit state is active
            // user inserting currency
            coin0 : begin
                $display("You inserted $0.05"); // display value user inserted
                // update user bank counter and user balance
                userBank[35:32] = userBank[35:32] + 1;
                total = total + 12'd5;
            end
            coin1 : begin
                $display("You inserted $0.10"); // display value user inserted
                // update user bank counter and user balance
                userBank[31:28] = userBank[31:28] + 1;
                total = total + 12'd10;
            end
            coin2 : begin
                $display("You inserted $0.25"); // display value user inserted
                // update user bank counter and user balance
                userBank[27:24] = userBank[27:24] + 1;
                total = total + 12'd25;
            end
            coin3 : begin
                $display("You inserted $0.50"); // display value user inserted
                // update user bank counter and user balance
                userBank[23:20] = userBank[23:20] + 1;
                total = total + 12'd50;
            end
            coin4 : begin
                $display("You inserted $1.00"); // display value user inserted
                // update user bank counter and user balance
                userBank[19:16] = userBank[19:16] + 1;
                total = total + 12'd100;
            end
            coin5 : begin
                $display("You inserted $2.00"); // display value user inserted
                // update user bank counter and user balance
                userBank[15:12] = userBank[15:12] + 1;
                total = total + 12'd200;
            end
            coin6 : begin
                $display("You inserted $5.00"); // display value user inserted
                // update user bank counter and user balance
                userBank[11:8] = userBank[11:8] + 1;
                total = total + 12'd500;
            end
            coin7 : begin
                $display("You inserted $10.00"); // display value user inserted
                // update user bank counter and user balance
                userBank[7:4] = userBank[7:4] + 1;
                total = total + 12'd1000;
            end
            coin8 : begin
                $display("You inserted $20.00"); // display value user inserted
                // update user bank counter and user balance
                userBank[3:0] = userBank[3:0] + 1;
                total = total + 12'd2000;
            end
        endcase           
        end
        // if state is deposit
        else if(select)begin
            // set choice to format of input
            choice = currCommand[15:4];
            $display("choice is: %h", choice);
            // simulate vending machine selection input format
            casex (choice)
                12'hxAx: begin   
                    if(price[choice[3:0] - 1] <= balance)begin // check if user has enough balance
                        // save price of item selected
                        purchase = price[choice[3:0] - 1];
                    end 
                end
                12'hxBx: begin   
                    if(price[choice[3:0] + 8] <= balance)begin // check if user has enough balance
                        // save price of item selected
                        purchase = price[choice[3:0] + 8]; 
                    end
                end
                12'hxCx: begin   
                    if(price[choice[3:0] + 17] <= balance)begin // check if user has enough balance
                        // save price of item selected
                        purchase = price[choice[3:0] + 17];
                    end
                end
                12'hxDx: begin   
                    if(price[choice[3:0] + 26] <= balance)begin // check if user has enough balance
                        // save price of item selected
                        purchase = price[choice[3:0] + 26];
                    end 
                end
                12'hxEx: begin   
                    if(price[choice[3:0] + 35] <= balance)begin // check if user has enough balance
                        // save price of item selected
                        purchase = price[choice[3:0] + 35];
                    end 
                end
                12'hxFx: begin   
                    if(price[choice[3:0]  + 44] <= balance)begin // check if user has enough balance
                        // save price of item selected
                        purchase = price[choice[3:0]  + 44];
                    end
                end
                12'h10x: begin   
                    if(price[choice[3:0]  + 53] <= balance)begin // check if user has enough balance
                        // save price of item selected
                        purchase = price[choice[3:0]  + 53];
                    end
                end
                12'h11x: begin   
                    if(price[choice[3:0]  + 62] <= balance)begin // check if user has enough balance
                        // save price of item selected
                        purchase = price[choice[3:0]  + 62];
                    end
                end
            endcase  

            // check if user balance is enough for selected item
            if(total >= purchase)begin
                $display("Purchasing item %h, Price: %d cents", choice, purchase);
    
                total = total - purchase; // update user balance
                // distribute change to user 
                while(i < total)begin
                    // dispence 5 dollars change
                    if(((i + 500) <= total) && to > 0)begin // check if 5 dollars is applicable and is in bank inventory
                        i = i + 500;
                        fi = fi - 1;
                        $display("dispencing $5.00 change");
                    end
                    // dispence 2 dollars change   
                    else if(((i + 200) <= total) && to > 0)begin // check if 2 dollars is applicable and is in bank inventory
                        i = i + 200;
                        to = to - 1;
                        $display("dispencing $2.00 change");
                    end
                    // dispence 1 dollar change
                    else if(((i + 100) <= total) && on > 0)begin // check if 1 dollar is applicable and is in bank inventory
                        i = i + 100;
                        on = on - 1;
                        $display("dispencing $1.00 change");
                    end
                    // dispence half dollar change
                    else if(((i + 50) <= total) && ha > 0)begin // check if half dollar is applicable and is in bank inventory
                        i = i + 50;
                        ha = ha - 1;
                        $display("dispencing $0.50 change");
                    end
                    // dispence quarter change
                    else if(((i + 25) <= total) && qu > 0)begin // check if quarter is applicable and is in bank inventory
                        i = i + 25;
                        qu = qu - 1;
                        $display("dispencing $0.25 change");
                    end
                    // dispence nickel change
                    else if(((i + 5) <= total) && ni > 0)begin // check if nickel is applicable and is in bank inventory
                        i = i + 5;
                        ni = ni - 1;
                        $display("dispencing $0.05 change");
                    end
                    // bank does not have required currency to dispence change
                    else begin
                        $display("insufficent funds in bank.");
                        i = total;
                    end
                end
                // reset user inserted currency count after change given
                userBank = 0;
            end
            // user does not have enough balance for purchase
            else $display("Balance too low!");   
        end

        // cancel command selected
        else if(cancel)begin
            $display("Canceling transaction, returning remaining balance!");
            // return currency the user has inserted
            while(userBank > 0)begin
                // check each demonanation balance
                if(userBank[3:0] > 0)begin
                    tw = tw - 1; // update bank
                    userBank[3:0] = userBank[3:0] - 1; // update user bank
                    $display("dispencing $20.00");   
                end
                else if(userBank[7:4] > 0)begin
                        te = te - 1; // update bank
                        userBank[7:4] = userBank[7:4] - 1; // update user bank
                        $display("dispencing $10.00"); 
                end
                else if(userBank[11:8] > 0)begin
                        fi = fi - 1; // update bank
                        userBank[11:8] = userBank[11:8] - 1; // update user bank
                        $display("dispencing $5.00"); 
                end
                else if(userBank[15:12] > 0)begin
                        to = to - 1; // update bank
                        userBank[15:12] = userBank[15:12] - 1; // update user bank
                        $display("dispencing $2.00");
                end
                else if(userBank[19:16] > 0)begin
                        on = on - 1; // update bank
                        userBank[19:16] = userBank[19:16] - 1; // update user bank
                        $display("dispencing $1.00");
                end
                else if(userBank[23:20] > 0)begin
                        ha = ha - 1; // update bank
                        userBank[23:20] = userBank[23:20] - 1; // update user bank
                        $display("dispencing $0.50");
                end
                else if(userBank[27:24] > 0)begin
                        qu = qu - 1; // update bank
                        userBank[27:24] = userBank[27:24] - 1; // update user bank
                        $display("dispencing $0.25");
                end
                else if(userBank[31:28] > 0)begin
                        di = di - 1; // update bank
                        userBank[31:28] = userBank[31:28] - 1; // update user bank
                        $display("dispencing $0.10");
                end
                else if(userBank[35:32] > 0)begin
                        ni = ni - 1; // update bank
                        userBank[35:32] = userBank[35:32] - 1; // update user bank
                        $display("dispencing $0.05");
                end
            end
            total = 0; // update total user balance
        end   
    end

endmodule

/*
Module: testVending
            - Testbench for program
            - Handle file input
            - Load current command
            - Pass singals to vending machine
Author: Marco Ghercioiu
Ports:
    None
*/

module testVending;
    // define registers for signals
    reg clk, nickel, dime, quarter, half, one, two, five, ten, twenty, dispense, done;
    reg deposit, select, cancel, valid;
    // define register for the current command from file
    reg [15:0] currCommand;
    // define arrays for file input
    reg [7:0] bank[0:8];
    reg [15:0] commands[0:9];
    // array used to store one-hot choices
    reg [8:0] temp[0:9];
    // initialize
    initial begin: initialization
        // initialize state signals
        deposit = 0;
        select = 0;
        cancel = 0;
        valid = 1;
        // initialize one-hot selection options
        temp[0] = 9'b100000000; 
        temp[1] = 9'b010000000; 
        temp[2] = 9'b001000000; 
        temp[3] = 9'b000100000; 
        temp[4] = 9'b000010000; 
        temp[5] = 9'b000001000; 
        temp[6] = 9'b000000100;
        temp[7] = 9'b000000010;
        temp[8] = 9'b000000001;
    end
    // for loop variables
    integer i, j; 
    // pass signals to vending machine
    VendingMachine vm(clk, nickel, dime, quarter, half, one, two, five, ten, twenty, currCommand, deposit, select, cancel, valid);

    initial begin
        // load in text files to arrays
        $readmemh("commands.txt", commands);
        $readmemh("bank.txt", bank);


        // initialize bank
        for(i = 0; i < 10; i=i+1)begin
            for(j = 0; j < bank[i]; j=j+1)begin
                // add currency based on bank values
                #10 {nickel, dime, quarter, half, one, two, five, ten, twenty} = temp[i];
                // reset signal
                #10 {nickel, dime, quarter, half, one, two, five, ten, twenty} = 9'd0;
            end
        end
        valid = 0;
        // process requests
        for(i = 0; i < 10; i=i+1)begin
            // differentiate commands given from file
            casex (commands[i])
                // deposit command
                16'hxxx1: begin
                    // set signals
                    #10; currCommand = commands[i]; {nickel, dime, quarter, half, one, two, five, ten, twenty} =  commands[i][12:4]; 
                    valid = 1; deposit = 1; select = 0; cancel = 0;     
                end
                // select command
                16'hxxx2: begin
                    // set signals
                    #10; currCommand = commands[i]; valid = 0; deposit = 0; select = 1; cancel = 0;
                end
                // cancel command
                16'hxxx3: begin
                    // set signals
                    #10; currCommand = commands[i]; valid = 0; deposit = 0; select = 0; cancel = 1;
                end
            endcase
        end
    // end program
    #100;
    $finish;
    end
    // update clock
    initial begin
        clk = 1; #5 clk = 0;
            forever begin
                #5 clk = 1; #5 clk = 0;
            end
    end
endmodule