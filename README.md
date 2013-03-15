P3 Overview
============

The **Primitive Profiling Parser** (or *P3*) is a tiny tool to calculate averages from the
file-based output of a hand-rolled profiler.

Here's how it works:

Your profiler must write a file with two columns (separated by a tab character).
The first column must contain some identifer (like a function name) and the second
column must contain a decimal number representing how long the identified entity ran.

When you have such a file, run `p3` like this:

    ./p3 <filename>

or like this:

    cat <filename> | ./p3

and you will get the average time spent for each unique entity along with some other information.


Example
-------

Let's say your program keeps appending to a file called `data.txt`. A small cross-section of
`data.txt` could look something like this:

    groupLogsByUser	0.00500
    ApiActivityLogger::sendLogsForUser	2.25004
    ApiActivityLogger::sendLogsForUser	2.24770
    ApiActivityLogger::sendLogsForUserInBatches	4.52228
    SqliteLogGatherer::resolveLogs	0.05343
    ApiActivityLogger::logActivity	4.59713
    getMaxIdFromQueryResult	0.00571
    SqliteQueuedLogGatherer::getQueryResult	1.42582
    SqliteLogGatherer::convertRowToLog	0.00208
    SqliteLogGatherer::convertRowToLog	0.00020
    Total	11.06091

where the first column is some unique name and the second is the time spent for that entity.

Running `./p3 data.txt` will give you something like this to `stdout`:

    ID                                                AVERAGE                  COUNT           SUM
    getMaxIdFromQueryResult                           5.687253886010365e-3     x193            =1.0976400000000004
    SqliteQueuedLogGatherer::getQueryResult           1.0012469430051805       x193            =193.24065999999982
    SqliteLogGatherer::convertRowToLog                8.205776706964147e-4     x385583         =316.4008000001357
    SqliteLogGatherer::getLogs                        6.323538906250004        x192            =1214.1194700000008
    groupLogsByUser                                   5.138593749999997e-3     x192            =0.9866099999999995
    ApiActivityLogger::sendLogsForUser                2.2612985937500003       x384            =868.3386600000001
    ApiActivityLogger::sendLogsForUserInBatches       4.543974554973821        x191            =867.8991399999999
    SqliteLogGatherer::resolveLogs                    6.470340314136125e-2     x191            =12.358349999999998
    ApiActivityLogger::logActivity                    4.6310171204188455       x191            =884.5242699999995
    Total                                             10.965333507853408       x191            =2094.378700000001


Building
========

To build, run the following:

    ghc -O2 --make p3.hs
