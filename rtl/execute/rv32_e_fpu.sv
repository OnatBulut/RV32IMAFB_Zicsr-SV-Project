`timescale 1ns / 1ps
`include "defines_header.svh"

module rv32_e_fpu (input  logic [`ALU_CONTROL_WIDTH-1:0] fpu_control_i,
                   input  logic [31:0] src_a_i, src_b_i, src_c_i,
                   
                   output logic [31:0] result_o);
                   


// todo : tasklar modullestirilecek, mul ve div islemler / veya * ile yapılmayıp ayrı bir modul ile yapilacak, FCLASS.S düzeltilecek.

task automatic fp32_add(
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] result
);
    // Parçalar
    logic sign_a, sign_b, sign_res;
    logic [7:0] exp_a, exp_b, exp_diff, exp_res;
    logic [23:0] frac_a, frac_b;
    logic [24:0] frac_shifted, frac_sum;
    logic [7:0] exp_final;
    logic [22:0] frac_final;
    
    begin
        // 1. Parçaları ayır
        sign_a = a[31];
        sign_b = b[31];
        exp_a  = a[30:23];
        exp_b  = b[30:23];
        frac_a = (exp_a == 0) ? {1'b0, a[22:0]} : {1'b1, a[22:0]};
        frac_b = (exp_b == 0) ? {1'b0, b[22:0]} : {1'b1, b[22:0]};

        // 2. Exponent hizalama
        if (exp_a > exp_b) begin
            exp_diff = exp_a - exp_b;
            frac_b = frac_b >> exp_diff;
            exp_res = exp_a;
        end else begin
            exp_diff = exp_b - exp_a;
            frac_a = frac_a >> exp_diff;
            exp_res = exp_b;
        end

        // 3. Toplama (aynı işaret varsayımıyla)
        frac_sum = frac_a + frac_b;
        sign_res = sign_a; // işaretler farklıysa bu logic genişletilmeli

        // 4. Normalize
        if (frac_sum[24]) begin
            frac_sum = frac_sum >> 1;
            exp_res = exp_res + 1;
        end

        // 5. Yuvarla (şimdilik sadece truncate)
        frac_final = frac_sum[22:0];
        exp_final = exp_res;

        // 6. Sonuç yapısı
        result = {sign_res, exp_final, frac_final};
    end
endtask

task automatic fp32_sub(
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] result
);
    logic sign_a, sign_b, sign_res;
    logic [7:0] exp_a, exp_b, exp_diff, exp_res;
    logic [23:0] frac_a, frac_b;
    logic [24:0] frac_diff;
    logic [7:0] exp_final;
    logic [22:0] frac_final;

    begin
        sign_a = a[31];
        sign_b = b[31];
        exp_a  = a[30:23];
        exp_b  = b[30:23];
        frac_a = (exp_a == 0) ? {1'b0, a[22:0]} : {1'b1, a[22:0]};
        frac_b = (exp_b == 0) ? {1'b0, b[22:0]} : {1'b1, b[22:0]};

        // Exponent hizalama
        if (exp_a > exp_b) begin
            exp_diff = exp_a - exp_b;
            frac_b = frac_b >> exp_diff;
            exp_res = exp_a;
        end else begin
            exp_diff = exp_b - exp_a;
            frac_a = frac_a >> exp_diff;
            exp_res = exp_b;
        end

        // Büyüklük karşılaştır
        if ($unsigned(a[30:0]) >= $unsigned(b[30:0])) begin
            frac_diff = frac_a - frac_b;
            sign_res = sign_a;
        end else begin
            frac_diff = frac_b - frac_a;
            sign_res = ~sign_a;  // a < b olduğu için işaret değişir
        end

        // Normalize
        for (int i = 0; i < 23; i++) begin
            if (frac_diff[23] == 0 && exp_res > 0) begin
                frac_diff = frac_diff << 1;
                exp_res = exp_res - 1;
            end
        end    

        frac_final = frac_diff[22:0];
        exp_final = exp_res;

        result = {sign_res, exp_final, frac_final};
    end
endtask

/*
task automatic fp32_sub(
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] result
);
    logic [31:0] b_neg;

    begin
        // B sayısının işaret bitini ters çevir (negate)
        b_neg = {~b[31], b[30:0]};

        // Toplama task'ini çağır
        fp32_add(a, b_neg, result);
    end
endtask
*/
/*task automatic fp32_mul(
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] result
);
    logic sign_a, sign_b, sign_res;
    logic [7:0] exp_a, exp_b, exp_res;
    logic [23:0] frac_a, frac_b;
    logic [47:0] product;
    logic [22:0] frac_final;
    logic [7:0] exp_final;

    begin
        // 1. Ayrıştır
        sign_a = a[31];
        sign_b = b[31];
        exp_a  = a[30:23];
        exp_b  = b[30:23];
        frac_a = (exp_a == 0) ? {1'b0, a[22:0]} : {1'b1, a[22:0]};
        frac_b = (exp_b == 0) ? {1'b0, b[22:0]} : {1'b1, b[22:0]};
        sign_res = sign_a ^ sign_b;

        // 2. Çarpım
        product = frac_a * frac_b;

        // 3. Normalize
        if (product[47]) begin
            frac_final = product[46:24]; // shift right
            exp_res = exp_a + exp_b - 127 + 1;
        end else begin
            frac_final = product[45:23];
            exp_res = exp_a + exp_b - 127;
        end

        exp_final = exp_res;

        // 4. Oluştur
        result = {sign_res, exp_final, frac_final};
    end
endtask

task automatic fp32_div(
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] result
);
    logic sign_a, sign_b, sign_res;
    logic [7:0] exp_a, exp_b, exp_res;
    logic [23:0] frac_a, frac_b;
    logic [47:0] dividend, quotient;
    logic [22:0] frac_final;
    logic [7:0] exp_final;

    begin
        // 1. Ayır
        sign_a = a[31];
        sign_b = b[31];
        exp_a  = a[30:23];
        exp_b  = b[30:23];
        frac_a = (exp_a == 0) ? {1'b0, a[22:0]} : {1'b1, a[22:0]};
        frac_b = (exp_b == 0) ? {1'b0, b[22:0]} : {1'b1, b[22:0]};
        sign_res = sign_a ^ sign_b;

        // 2. Mantissa bölme (48 bitlik precision)
        dividend = {24'b0, frac_a} << 23; // genişlet ve hizala
        quotient = dividend / frac_b;

        // 3. Normalize
        if (quotient[23] == 0) begin
            quotient = quotient << 1;
            exp_res = exp_a - exp_b + 127 - 1;
        end else begin
            exp_res = exp_a - exp_b + 127;
        end

        frac_final = quotient[22:0];
        exp_final = exp_res;

        // 4. Sonuç
        result = {sign_res, exp_final, frac_final};
    end
endtask

task automatic fp32_sqrt(      
    input  logic [31:0] a,
    output logic [31:0] result
);
    logic sign_a;
    logic [7:0] exp_a, exp_res;
    logic [23:0] frac_a, guess;
    logic [31:0] temp_result;

    begin
        sign_a = a[31];
        exp_a = a[30:23];
        frac_a = (exp_a == 0) ? {1'b0, a[22:0]} : {1'b1, a[22:0]};

        if (sign_a == 1'b1) begin
            result = 32'h7FC00000;
        end else begin
            // Dummy square root approximation using bit shifts
            exp_res = ((exp_a - 127) >> 1) + 127;
            guess = frac_a >> 1; // crude approximation
            result = {1'b0, exp_res, guess[22:0]};
        end
    end
endtask

task automatic fp32_fma(
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [31:0] c,
    input  logic negate_mul,
    input  logic negate_result,
    output logic [31:0] result
);
    logic [31:0] mul_res, neg_mul_res, tmp_result;

    begin
        fp32_mul(a, b, mul_res);

        if (negate_mul)
            fp32_sub(32'b0, mul_res, neg_mul_res);  // -mul
        else
            neg_mul_res = mul_res;

        if (negate_result)
            fp32_sub(neg_mul_res, c, tmp_result);   // -mul - c
        else
            fp32_add(neg_mul_res, c, tmp_result);   // mul + c

        result = tmp_result;
    end
endtask
*/

/* 
task automatic fp32_fma(
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [31:0] c,
    input  logic negate_mul,
    input  logic negate_result,
    output logic [31:0] result
);
    logic [31:0] mul_res, add_res, neg_mul_res;

    begin
        fp32_mul(a, b, mul_res);
        if (negate_mul)
            fp32_sub(32'b0, mul_res, neg_mul_res);  // -mul
        else
            neg_mul_res = mul_res;

        if (negate_result)
            fp32_sub(neg_mul_res, c, result);       // -mul - c
        else
            fp32_add(neg_mul_res, c, result);       // mul + c
    end
endtask
*/
task automatic fp32_min(
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] result
);
    logic is_nan_a, is_nan_b;

    begin
        is_nan_a = (a[30:23] == 8'hFF) && (a[22:0] != 0);
        is_nan_b = (b[30:23] == 8'hFF) && (b[22:0] != 0);

        if (is_nan_a && is_nan_b)
            result = 32'h7FC00000; // QNaN
        else if (is_nan_a)
            result = b;
        else if (is_nan_b)
            result = a;
        else
            result = ($signed(a) < $signed(b)) ? a : b;
    end
endtask
 
task automatic fp32_max(
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] result
);
    logic is_nan_a, is_nan_b;

    begin
        is_nan_a = (a[30:23] == 8'hFF) && (a[22:0] != 0);
        is_nan_b = (b[30:23] == 8'hFF) && (b[22:0] != 0);

        if (is_nan_a && is_nan_b)
            result = 32'h7FC00000;
        else if (is_nan_a)
            result = b;
        else if (is_nan_b)
            result = a;
        else
            result = ($signed(a) > $signed(b)) ? a : b;
    end
endtask

 /*
task automatic fp32_to_int(
    input  logic [31:0] a,
    output logic [31:0] result
);
    logic sign;
    logic [7:0] exp;
    logic [23:0] frac;
    integer shift;
    logic [31:0] int_val;

    begin
        sign = a[31];
        exp  = a[30:23];
        frac = {1'b1, a[22:0]}; // implicit 1

        shift = exp - 127;

        if (shift >= 31) begin
            result = 32'h7FFFFFFF; // overflow koruması
        end else if (shift < 0) begin
            result = 0;
        end else begin
            int_val = frac << shift;
            result = sign ? -int_val : int_val;
        end
    end
endtask
*/

task automatic fp32_to_int(
    input  logic [31:0] a,
    output logic [31:0] result
);
    logic sign;
    logic [7:0] exp;
    logic [23:0] frac;
    integer shift;
    logic [31:0] int_val;

    begin
        sign = a[31];
        exp  = a[30:23];
        frac = {1'b1, a[22:0]};  // normalize mantissa

        shift = exp - 127;

        if (shift < 0) begin
            result = 0;
        end else if (shift > 31) begin
            result = 32'h7FFFFFFF; // overflow
        end else begin
            int_val = frac >> (23 - shift);
            result = sign ? -int_val : int_val;
        end
    end
endtask

task automatic fp32_to_uint(
    input  logic [31:0] a,
    output logic [31:0] result
);
    logic sign;
    logic [7:0] exp;
    logic [23:0] frac;
    integer shift;

    begin
        sign = a[31];
        exp  = a[30:23];
        frac = {1'b1, a[22:0]}; // normalize mantissa
        shift = exp - 127;

        if (sign) begin
            result = 32'b0; // negatif sayı → unsigned olmaz
        end else if (shift < 0) begin
            result = 0;
        end else if (shift >= 32) begin
            result = 32'hFFFFFFFF; // overflow
        end else begin
            result = frac >> (23 - shift);
        end
    end
endtask


task automatic int_to_fp32(
    input  logic signed [31:0] a,
    output logic [31:0] result
);
    logic sign;
    logic [31:0] abs_val;
    integer i;
    logic [7:0] exponent;
    logic [22:0] mantissa;
    logic [31:0] shifted;

    begin
        sign = a[31];
        abs_val = sign ? -a : a;

        exponent = 0;
        mantissa = 0;

        for (i = 30; i >= 0; i--) begin
            if (abs_val[i]) begin
                exponent = i + 127;
                shifted = abs_val << (31 - i);
                mantissa = shifted[30:8];
                break;
            end
        end

        result = (a == 0) ? 32'b0 : {sign, exponent, mantissa};
    end
endtask

task automatic uint_to_fp32(
    input  logic [31:0] a,
    output logic [31:0] result
);
    integer i;
    logic [7:0] exponent;
    logic [22:0] mantissa;
    logic [31:0] shifted;

    begin
        exponent = 0;
        mantissa = 0;

        for (i = 31; i >= 0; i--) begin
            if (a[i]) begin
                exponent = i + 127;
                shifted = a << (31 - i);
                mantissa = shifted[30:8];
                break;
            end
        end

        result = (a == 0) ? 32'b0 : {1'b0, exponent, mantissa};
    end
endtask

function automatic logic is_nan(input logic [31:0] val);
    return ((val[30:23] == 8'hFF) && (val[22:0] != 0));
endfunction

task automatic fp32_eq(
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] result
);
    if (is_nan(a) || is_nan(b))
        result = 0;
    else
        result = (a == b) ? 1 : 0;
endtask

task automatic fp32_lt(
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] result
);
    if (is_nan(a) || is_nan(b))
        result = 0;
    else
        result = ($signed(a) < $signed(b)) ? 1 : 0;
endtask

task automatic fp32_le(
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] result
);
    if (is_nan(a) || is_nan(b))
        result = 0;
    else
        result = ($signed(a) <= $signed(b)) ? 1 : 0;
endtask

task automatic fp32_class(
    input  logic [31:0] a,
    output logic [31:0] result
);
    logic sign;
    logic [7:0] exp;
    logic [22:0] frac;

    begin
        sign = a[31];
        exp  = a[30:23];
        frac = a[22:0];

        result = 32'b0;

        if (exp == 8'hFF) begin
            if (frac == 0) result[sign ? 0 : 7] = 1; // Inf
            else if (frac[22] == 1) result[9] = 1;    // QNaN
            else result[8] = 1;                       // SNaN
        end else if (exp == 0) begin
            if (frac == 0) result[sign ? 3 : 4] = 1;   // ±0
            else result[sign ? 2 : 5] = 1;             // Subnormal
        end else begin
            result[sign ? 1 : 6] = 1; // Normal number
        end
    end
endtask

always_comb begin
    case(fpu_control_i)
        ALU_FLW:     result_o = src_a_i + src_b_i; // Placeholder for memory load address calculation
        ALU_FSW:     result_o = src_a_i + src_b_i; // Placeholder for memory store address calculation

        ALU_FADD:    fp32_add(src_a_i, src_b_i, result_o);
        ALU_FSUB:    fp32_sub(src_a_i, src_b_i, result_o);
        //ALU_FMUL:    fp32_mul(src_a_i, src_b_i, result_o);
        //ALU_FDIV:    fp32_div(src_a_i, src_b_i, result_o);
        //ALU_FSQRT:   fp32_sqrt(src_a_i, result_o);
        
        //ALU_FMADD:  fp32_fma(src_a_i, src_b_i, src_c_i, 0, 0, result_o);
        //ALU_FMSUB:  fp32_fma(src_a_i, src_b_i, src_c_i, 0, 1, result_o);
        //ALU_FNMSUB: fp32_fma(src_a_i, src_b_i, src_c_i, 1, 1, result_o);
        //ALU_FNMADD: fp32_fma(src_a_i, src_b_i, src_c_i, 1, 0, result_o);

        ALU_FSGNJ:   result_o = {src_b_i[31], src_a_i[30:0]};
        ALU_FSGNJN:  result_o = {~src_b_i[31], src_a_i[30:0]};
        ALU_FSGNJX:  result_o = {src_a_i[31] ^ src_b_i[31], src_a_i[30:0]};

        ALU_FMIN: fp32_min(src_a_i, src_b_i, result_o);
        ALU_FMAX: fp32_max(src_a_i, src_b_i, result_o);
        
        ALU_FCVTWS:  fp32_to_int(src_a_i, result_o);
        ALU_FCVTWUS: fp32_to_uint(src_a_i, result_o);
        ALU_FCVTSW:  int_to_fp32(signed'(src_a_i), result_o);
        ALU_FCVTSWU: uint_to_fp32(src_a_i, result_o);


        ALU_FMVXW:   result_o = src_a_i; 
        ALU_FMVWX:   result_o = src_a_i;

        ALU_FEQ: fp32_eq(src_a_i, src_b_i, result_o);
        ALU_FLT: fp32_lt(src_a_i, src_b_i, result_o);
        ALU_FLE: fp32_le(src_a_i, src_b_i, result_o);

        ALU_FCLASS: fp32_class(src_a_i, result_o);

        default:     result_o = 'bx;
    endcase
end

endmodule
