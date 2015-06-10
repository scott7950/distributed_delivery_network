#!/usr/bin/perl

my $run_opt;
$run_opt->{COV} = 0;
$run_opt->{TEST} = "all";

while(my $switch = shift(@ARGV)) {
    if($switch =~ /^-cov$/) {
        $run_opt->{COV} = 1;
    } elsif($switch =~ /^-test$/) {
        $run_opt->{TEST} = shift(@ARGV);
    } else {
        if(defined($run_opt->{ARG})) {
            $run_opt->{ARG} .= " ".$switch;
        } else {
            $run_opt->{ARG} = $switch;
        }
    }
}

my $test_lst_file = "../test/test.lst";

if($run_opt->{TEST} eq "all") {
    my $first_test = 1;

    open FH, "< $test_lst_file" or die "Cannot open the file $test_lst_file: $!\n";
    while(<FH>) {
        chomp;

        print "Running test $_\n";

        my $run_cmd = "make -f ../script/Makefile TESTNAME=$_";
        if($run_opt->{COV} == 1) {
            $run_cmd .= " COV=1";
        }
        if($first_test != 1) {
            $run_cmd .= " run";
        }

        `$run_cmd`;

        $first_test = 0;

    }
    close FH;

    if($run_opt->{COV} == 1) {
        `vcover merge cov_all.ucdb *.ucdb`;
        `vcover report -html -htmldir cov -verbose cov_all.ucdb`;
    }
} else {
    print "Running test $run_opt->{TEST}\n";
    if($run_opt->{COV} == 1) {
        `make -f ../script/Makefile TESTNAME=$run_opt->{TEST} COV=1`;
        `mv cov.ucdb $run_opt->{TEST}.ucdb`;
        `vcover report -html -htmldir cov -verbose $run_opt->{TEST}.ucdb`;
    } else {
        `make -f ../script/Makefile TESTNAME=$run_opt->{TEST}`;
    }
}

