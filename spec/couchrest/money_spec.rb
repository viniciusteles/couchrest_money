require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module CouchRest
  describe Money do
    before(:each) do
      I18n.locale = "pt-BR"
    end
    describe "initialization" do
      describe "from Hash" do
        it "contains an integer" do
          Money.new(:amount => 1)[:amount].should == 1
          Money.new('amount' => 1)[:amount].should == 1
        end

        it "contains a Float" do
          Money.new(:amount => 1.0)[:amount].should == 100
          Money.new('amount' => 1.0)[:amount].should == 100
        end

        it "contains a String with an Integer" do
          Money.new(:amount => '1')[:amount].should == 100
          Money.new('amount' => '1')[:amount].should == 100
        end

        it "contains a String with a Float" do
          Money.new(:amount => '1.0')[:amount].should == 100
          Money.new('amount' => '1.0')[:amount].should == 100
        end

        it "contains a BigDecimal" do
          Money.new(:amount => BigDecimal.new('1.0'))[:amount].should == 100
          Money.new('amount' => BigDecimal.new('1.0'))[:amount].should == 100
        end
      end

      describe "from Money" do
        it "creates another Money with the same amount" do
          Money.new(:amount => 1.cent)[:amount].should == 1
          Money.new(:amount => 1.real)[:amount].should == 100
        end
      end
    end

    describe "amount" do
      context "storing" do
        context "@amount stores whatever it receives to play nicely in Rails forms when validation errors arise" do
          before(:each) do
            @money = Money.new
          end

          it "has no amount" do
            @money.amount.should be_nil
          end

          it "keeps a Fixnum unchanged" do
            @money.amount = 1
            @money.amount.should == 1
          end

          it "keeps a Float unchanged" do
            @money.amount = 1.0
            @money.amount.should == 1.0
          end

          it "keeps a BigDecimal unchanged" do
            @money.amount = BigDecimal.new("1.0")
            @money.amount.should == BigDecimal.new("1.0")
          end

          it "keeps a String containing a number unchanged" do
            @money.amount = "1"
            @money.amount.should == "1"
          end

          it "keeps a String containing a non number unchanged" do
            @money.amount = "not a number"
            @money.amount.should == "not a number"
          end

          it "keeps a Date unchanged" do
            @money.amount = Date.today
            @money.amount.should == Date.today
          end
        end

        context "the key ['amount'] only stores valid amounts" do
          before(:each) do
            @money = Money.new
          end

          it "stores a Fixnum unchanged" do
            @money.amount = 1
            @money['amount'].should == 1
          end

          it "stores a Float" do
            @money.amount = 1.0
            @money['amount'].should == 100
          end

          it "stores a BigDecimal" do
            @money.amount = BigDecimal.new("10.4056")
            @money['amount'].should == 1041
          end

          context "String" do
            it "stores a String containig an integer" do
              @money.amount = "1"
              @money['amount'].should == 100
            end

            it "stores a String containing a Float" do
              @money.amount = "1.0"
              @money['amount'].should == 100
            end

            it "stores nothing when the content is invalid" do
              @money.amount = "invalid"
              @money['amount'].should be_nil
            end

            it "keeps ['amount'] unchanged when it receives an invalid string" do
              @money['amount'] = 200
              @money.amount.should == 200
              @money.amount = 'invalid'
              @money.amount.should == 'invalid'
              @money['amount'].should == 200
            end
          end

          it "stores nothing when the content is invalid" do
            @money.amount = Date.today
            @money['amount'].should be_nil
          end

          context "scenarios by data type" do
            def stores_amount_as(hash)
              value = hash.keys.first
              expected_amount = hash.values.first
              money = Money.new
              money.amount = value
              money['amount'].should == expected_amount
            end

            context "from Money" do
              it { stores_amount_as Money.new(:amount => 1) => 1 }
              it { stores_amount_as Money.new(:amount => '1') => 100 }
              it { stores_amount_as Money.new(:amount => '1.0') => 100 }
              it { stores_amount_as Money.new(:amount => 1.0) => 100 }
              it { stores_amount_as Money.new(:amount => BigDecimal.new('1.0')) => 100 }
            end

            context "from NilClass" do
              it { stores_amount_as nil => nil }
            end

            context "from Integer" do
              it { stores_amount_as 0  =>  0 }
              it { stores_amount_as 1  =>  1 }
              it { stores_amount_as -1 => -1 }
              it { stores_amount_as 2  =>  2 }
              it { stores_amount_as -2 => -2 }
            end

            context "from Float" do
              it { stores_amount_as   0.0 =>    0 }
              it { stores_amount_as   1.0 =>  100 }
              it { stores_amount_as  -1.0 => -100 }
              it { stores_amount_as  0.01 =>    1 }
              it { stores_amount_as   0.1 =>   10 }
              it { stores_amount_as -0.01 =>   -1 }
              it { stores_amount_as  -0.1 =>  -10 }
              it { stores_amount_as 0.014 =>    1 }
              it { stores_amount_as 0.015 =>    2 }
            end

            context "from BigDecimal" do
              it { stores_amount_as   BigDecimal.new('0.0') =>    0 }
              it { stores_amount_as   BigDecimal.new('1.0') =>  100 }
              it { stores_amount_as  BigDecimal.new('-1.0') => -100 }
              it { stores_amount_as  BigDecimal.new('0.01') =>    1 }
              it { stores_amount_as   BigDecimal.new('0.1') =>   10 }
              it { stores_amount_as BigDecimal.new('-0.01') =>   -1 }
              it { stores_amount_as  BigDecimal.new('-0.1') =>  -10 }
              it { stores_amount_as BigDecimal.new('0.014') =>    1 }
              it { stores_amount_as BigDecimal.new('0.015') =>    2 }
            end

            context "from String" do
              context "containing a Fixnum" do
                it { stores_amount_as "0"                     =>    0 }
                it { stores_amount_as "        0     "        =>    0 }
                it { stores_amount_as "      00000    "       =>    0 }
                it { stores_amount_as "  -000 "               =>    0 }
                it { stores_amount_as "1"                     =>  100 }
                it { stores_amount_as "       1  "            =>  100 }
                it { stores_amount_as "      0000001   "      =>  100 }
                it { stores_amount_as "-1"                    => -100 }
                it { stores_amount_as "        -1    "        => -100 }
                it { stores_amount_as "    -000000000001    " => -100 }
              end

              context "containing a Float" do
                context "using '.' as a decimal delimiter" do
                  it { stores_amount_as "0.0"                          =>    0 }
                  it { stores_amount_as "    0.0     "                 =>    0 }
                  it { stores_amount_as "0."                           =>    0 }
                  it { stores_amount_as "      0.   "                  =>    0 }
                  it { stores_amount_as "     .0   "                   =>    0 }
                  it { stores_amount_as "    0000000000000000.00000 "  =>    0 }
                  it { stores_amount_as "        000000000.   "        =>    0 }
                  it { stores_amount_as "        .0000000 "            =>    0 }
                  it { stores_amount_as "1.0"                          =>  100 }
                  it { stores_amount_as "      1.0    "                =>  100 }
                  it { stores_amount_as "1."                           =>  100 }
                  it { stores_amount_as "     1.   "                   =>  100 }
                  it { stores_amount_as "    00000001. "               =>  100 }
                  it { stores_amount_as "      000001.00000 "          =>  100 }
                  it { stores_amount_as "0.01"                         =>    1 }
                  it { stores_amount_as "        0.01    "             =>    1 }
                  it { stores_amount_as ".01"                          =>    1 }
                  it { stores_amount_as "       .01   "                =>    1 } 
                  it { stores_amount_as "       .0100000   "           =>    1 } 
                  it { stores_amount_as "     0.1  "                   =>   10 }
                  it { stores_amount_as "     000.10000  "             =>   10 }
                  it { stores_amount_as "   .1   "                     =>   10 }
                  it { stores_amount_as "   .100000   "                =>   10 }
                  it { stores_amount_as "-0.0"                         =>    0 }
                  it { stores_amount_as "    -0.0     "                =>    0 }
                  it { stores_amount_as "-0."                          =>    0 }
                  it { stores_amount_as "      -0.   "                 =>    0 }
                  it { stores_amount_as "     -.0   "                  =>    0 }
                  it { stores_amount_as "    -0000000000000000.00000 " =>    0 }
                  it { stores_amount_as "        -000000000.   "       =>    0 }
                  it { stores_amount_as "        -.0000000 "           =>    0 }
                  it { stores_amount_as "-1.0"                         => -100 }
                  it { stores_amount_as "      -1.0    "               => -100 }
                  it { stores_amount_as "-1."                          => -100 }
                  it { stores_amount_as "     -1.   "                  => -100 }
                  it { stores_amount_as "    -00000001. "              => -100 }
                  it { stores_amount_as "      -000001.00000 "         => -100 }
                  it { stores_amount_as "-0.01"                        =>   -1 }
                  it { stores_amount_as "        -0.01    "            =>   -1 }
                  it { stores_amount_as "-.01"                         =>   -1 }
                  it { stores_amount_as "       -.01   "               =>   -1 } 
                  it { stores_amount_as "       -.0100000   "          =>   -1 } 
                  it { stores_amount_as "     -0.1  "                  =>  -10 }
                  it { stores_amount_as "     -000.10000  "            =>  -10 }
                  it { stores_amount_as "   -.1   "                    =>  -10 }
                  it { stores_amount_as "   -.100000   "               =>  -10 }
                end

                context "using ',' as a decimal delimiter" do
                  it { stores_amount_as "0,0"                          =>    0 }
                  it { stores_amount_as "    0,0     "                 =>    0 }
                  it { stores_amount_as "0,"                           =>    0 }
                  it { stores_amount_as "      0,   "                  =>    0 }
                  it { stores_amount_as "     ,0   "                   =>    0 }
                  it { stores_amount_as "    0000000000000000,00000 "  =>    0 }
                  it { stores_amount_as "        000000000,   "        =>    0 }
                  it { stores_amount_as "        ,0000000 "            =>    0 }
                  it { stores_amount_as "1,0"                          =>  100 }
                  it { stores_amount_as "      1,0    "                =>  100 }
                  it { stores_amount_as "1,"                           =>  100 }
                  it { stores_amount_as "     1,   "                   =>  100 }
                  it { stores_amount_as "    00000001, "               =>  100 }
                  it { stores_amount_as "      000001,00000 "          =>  100 }
                  it { stores_amount_as "0,01"                         =>    1 }
                  it { stores_amount_as "        0,01    "             =>    1 }
                  it { stores_amount_as ",01"                          =>    1 }
                  it { stores_amount_as "       ,01   "                =>    1 } 
                  it { stores_amount_as "       ,0100000   "           =>    1 } 
                  it { stores_amount_as "     0,1  "                   =>   10 }
                  it { stores_amount_as "     000,10000  "             =>   10 }
                  it { stores_amount_as "   ,1   "                     =>   10 }
                  it { stores_amount_as "   ,100000   "                =>   10 }
                  it { stores_amount_as "-0,0"                         =>    0 }
                  it { stores_amount_as "    -0,0     "                =>    0 }
                  it { stores_amount_as "-0,"                          =>    0 }
                  it { stores_amount_as "      -0,   "                 =>    0 }
                  it { stores_amount_as "     -,0   "                  =>    0 }
                  it { stores_amount_as "    -0000000000000000,00000 " =>    0 }
                  it { stores_amount_as "        -000000000,   "       =>    0 }
                  it { stores_amount_as "        -,0000000 "           =>    0 }
                  it { stores_amount_as "-1,0"                         => -100 }
                  it { stores_amount_as "      -1,0    "               => -100 }
                  it { stores_amount_as "-1,"                          => -100 }
                  it { stores_amount_as "     -1,   "                  => -100 }
                  it { stores_amount_as "    -00000001, "              => -100 }
                  it { stores_amount_as "      -000001,00000 "         => -100 }
                  it { stores_amount_as "-0,01"                        =>   -1 }
                  it { stores_amount_as "        -0,01    "            =>   -1 }
                  it { stores_amount_as "-,01"                         =>   -1 }
                  it { stores_amount_as "       -,01   "               =>   -1 } 
                  it { stores_amount_as "       -,0100000   "          =>   -1 } 
                  it { stores_amount_as "     -0,1  "                  =>  -10 }
                  it { stores_amount_as "     -000,10000  "            =>  -10 }
                  it { stores_amount_as "   -,1   "                    =>  -10 }
                  it { stores_amount_as "   -,100000   "               =>  -10 }
                end
              end

              context "containg a text that can't be converted to a number" do
                it { stores_amount_as "not a number" => nil }
              end
            end
          end
        end

        context "extensions" do
          def has_amount(hash)
            money = hash.keys.first
            expected_amount = hash.values.first
            money['amount'].should == expected_amount
          end

          it { has_amount 1.real =>  100 }
          it { has_amount 2.reais => 200 }
          it { has_amount 3.reals => 300 }
          it { has_amount 1.cent =>    1 }
          it { has_amount 2.cents =>   2 }
          it { has_amount 1.centavo => 1 }
          it { has_amount 3.centavos=> 3 }
        end

      end

      context "loading" do
        before(:each) do
          @money = Money.new
        end

        context "from ['amount']" do
          it "is nil when it's initialized without any parameter" do
            @money.amount.should be_nil
          end

          it "loads from ['amount'] when @amount isn't defined yet" do
            @money['amount'] = 300
            @money.amount.should == 300
          end
        end

        context "from @amount" do
          it "loads from @amount when it's defined" do
            @money.instance_variable_set(:@amount, 400)
            @money.amount.should == 400
          end
        end
      end
    end

    describe "validations" do
      it "must hold an integer in the amount" do
        money = Money.new
        money.amount = "not an integer"
        money.valid?
        money.should have_errors
        money.should contain_error(:amount, "tem que ser um valor monetário válido")
      end
    end

    describe "to_f" do
      it "converts to Float" do
        1.real.to_f.should == 1.00
        1.cent.to_f.should == 0.01
      end
    end

    describe "to_s" do
      it "converts to String" do
        1.real.to_s.should == "1.00"
        1.cent.to_s.should == "0.01"
      end

      it "interpolates" do
        "#{1.real}".should == "1.00"
        "#{1.cent}".should == "0.01"
      end
    end

    describe "to_str" do
      it "converts to String" do
        1.0.real.to_str.should == "1.00"
        "1".centavo.to_str.should == "0.01"
      end
    end
  end
end

