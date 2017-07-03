/* ============================================================
 * This code is part of the 'apex-lang' open source project avaiable at:
 * 
 *      http://code.google.com/p/apex-lang/
 *
 * This code is licensed under the Apache License, Version 2.0.  You may obtain a 
 * copy of the License at:
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * ============================================================
 */
global with sharing class StopWatch {

    // running states
    global static final Integer STATE_UNSTARTED = 0;
    global static final Integer STATE_RUNNING = 1;
    global static final Integer STATE_STOPPED = 2;
    global static final Integer STATE_SUSPENDED = 3;

    // split state
    global static final Integer STATE_UNSPLIT = 10;
    global static final Integer STATE_SPLIT = 11;

    global Integer runningState = STATE_UNSTARTED;
    global Integer splitState = STATE_UNSPLIT;
    global Long startTime = -1;
    global Long stopTime = -1;

    global void start() {
        if (this.runningState == STATE_STOPPED) {
            throw new IllegalStateException('Stopwatch must be reset before being restarted. ');
        }
        if (this.runningState != STATE_UNSTARTED) {
            throw new IllegalStateException('Stopwatch already started. ');
        }
        this.stopTime = -1;
        this.startTime = System.currentTimeMillis();
        this.runningState = STATE_RUNNING;
    }

    global void stop() {
        if (this.runningState != STATE_RUNNING && this.runningState != STATE_SUSPENDED) {
            throw new IllegalStateException('Stopwatch is not running. ');
        }
        if (this.runningState == STATE_RUNNING) {
            this.stopTime = System.currentTimeMillis();
        }
        this.runningState = STATE_STOPPED;
    }

    global void reset() {
        this.runningState = STATE_UNSTARTED;
        this.splitState = STATE_UNSPLIT;
        this.startTime = -1;
        this.stopTime = -1;
    }

    global void split() {
        if (this.runningState != STATE_RUNNING) {
            throw new IllegalStateException('Stopwatch is not running. ');
        }
        this.stopTime = System.currentTimeMillis();
        this.splitState = STATE_SPLIT;
    }

    global void unsplit() {
        if (this.splitState != STATE_SPLIT) {
            throw new IllegalStateException('Stopwatch has not been split. ');
        }
        this.stopTime = -1;
        this.splitState = STATE_UNSPLIT;
    }

    global void suspend() {
        if (this.runningState != STATE_RUNNING) {
            throw new IllegalStateException('Stopwatch must be running to suspend. ');
        }
        this.stopTime = System.currentTimeMillis();
        this.runningState = STATE_SUSPENDED;
    }

    global void resume() {
        if (this.runningState != STATE_SUSPENDED) {
            throw new IllegalStateException('Stopwatch must be suspended to resume. ');
        }
        this.startTime += (System.currentTimeMillis() - this.stopTime);
        this.stopTime = -1;
        this.runningState = STATE_RUNNING;
    }

    global Long getTime() {
        if (this.runningState == STATE_STOPPED || this.runningState == STATE_SUSPENDED) {
            return this.stopTime - this.startTime;
        } else if (this.runningState == STATE_RUNNING) {
            return System.currentTimeMillis() - this.startTime;
        }
        return 0;
    }

    global Long getSplitTime() {
        if (this.splitState != STATE_SPLIT) {
            throw new IllegalStateException('Stopwatch must be split to get the split time. ');
        }
        return this.stopTime - this.startTime;
    }

    global Long getStartTime() {
        if (this.runningState == STATE_UNSTARTED) {
            throw new IllegalStateException('Stopwatch has not been started');
        }
        return this.startTime;
    }

    global String toStr() {
        return Datetime.newInstance(getTime()).format();
    }

    global String toSplitString() {
        return Datetime.newInstance(getSplitTime()).format();
    }

}