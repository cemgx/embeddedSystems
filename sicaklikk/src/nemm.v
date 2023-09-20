module TemperatureSensor(
  input wire clk,            // Saat sinyali
  input wire reset,          // Sıfırlama sinyali
  input wire dht_data,       // DHT11 veri çıkışı

  output wire led_red,       // Kırmızı LED çıkışı
  output wire led_blue       // Mavi LED çıkışı
);

  reg led_red_reg;           // Kırmızı LED durumu
  reg led_blue_reg;          // Mavi LED durumu

  reg [7:0] temperature;     // Sıcaklık verisi

  // DHT11 veri okuma işlemi
  reg [39:0] dht_shift_reg;
  reg [7:0] dht_bit_counter;
  reg dht_valid_data;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      led_red_reg <= 1'b0;
      led_blue_reg <= 1'b0;
      temperature <= 8'h00;
      dht_shift_reg <= 40'b0;
      dht_bit_counter <= 8'h00;
      dht_valid_data <= 1'b0;
    end else begin
      // DHT11 veri okuma işlemi
      if (!dht_valid_data) begin
        dht_shift_reg <= {dht_shift_reg[38:0], dht_data};
        dht_bit_counter <= dht_bit_counter + 1'b1;

        if (dht_bit_counter == 8'h40) begin
          dht_valid_data <= 1'b1;
          temperature <= dht_shift_reg[23:16]; // Sıcaklık verisi DHT11'de 24-31 bitler arasında yer aldığı için bu aralığı seçiyoruz.
        end
      end

      // Sıcaklık değerine göre LED kontrolü
      if (temperature > 8'h1E) begin // 30 decimal = 1E hexadecimal
        led_red_reg <= 1'b1;
        led_blue_reg <= 1'b0;
      end else begin
        led_red_reg <= 1'b0;
        led_blue_reg <= 1'b1;
      end
    end
  end

  assign led_red = led_red_reg;
  assign led_blue = led_blue_reg;

endmodule
