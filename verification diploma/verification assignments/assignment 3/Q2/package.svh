package question_2_pkg;
  parameter int WIDTH = 4;

  class question_2_class;
    // random control fields
    rand logic rst_n_class, load_n_class, up_down_class, ce_class;
    rand logic [WIDTH-1:0] data_load_class;

    // variable that TB will fill with DUT count for coverage sampling
    logic [WIDTH-1:0] sampled_count;

    // Constraints / distributions
    constraint distribution {
      rst_n_class  dist {1 := 80, 0 := 20};
      load_n_class dist {0 := 70, 1 := 30};
      ce_class     dist {1 := 70, 0 := 30};
    }

    // Covergroup defined inside class (no event control here)
    covergroup counter_cov;
      // 1. load-data when load asserted and reset deasserted
      load_data_cp: coverpoint data_load_class
        iff (load_n_class == 0 && rst_n_class == 1);

      // 2. count-up values (sampled_count) when rst=1, ce=1, up_down=1
      count_up_cp: coverpoint sampled_count
        iff (rst_n_class == 1 && ce_class == 1 && up_down_class == 1);

      // 3. overflow detection (max -> 0) as transition bin
      count_up_overflow: coverpoint sampled_count
        iff (rst_n_class == 1 && ce_class == 1 && up_down_class == 1) {
        bins overflow = ({WIDTH{1'b1}} => 0);
      }

      // 4. count-down values when rst=1, ce=1, up_down=0
      count_down_cp: coverpoint sampled_count
        iff (rst_n_class == 1 && ce_class == 1 && up_down_class == 0);

      // 5. underflow detection (0 -> max) as transition bin
      count_down_underflow: coverpoint sampled_count
        iff (rst_n_class == 1 && ce_class == 1 && up_down_class == 0) {
        bins underflow = (0 => {WIDTH{1'b1}});
      }
    endgroup

    function new();
      counter_cov = new();
    endfunction

  endclass

endpackage
