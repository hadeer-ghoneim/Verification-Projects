package question_2_pkg ;

  parameter WIDTH = 4 ;

  class question_2_class ;
    rand logic rst_n_class, load_n_class, up_down_class, ce_class ;
    rand logic [WIDTH-1:0] data_load_class ;

    constraint distribution {
      rst_n_class  dist {1 := 80, 0 := 20};  // reset inactive most of the time
      load_n_class dist {0 := 70, 1 := 30};  // load active 70%
      ce_class     dist {1 := 70, 0 := 30};  // enable active 70%
    }
  endclass

endpackage