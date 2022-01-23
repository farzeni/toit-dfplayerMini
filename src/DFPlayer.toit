// Copyright (C) 2022 Fabrizio Arzeni.
// Use of this source code is governed by a MIT license that can
// be found in the LICENSE file.

import serial
import gpio
import uart show Port
import reader show BufferedReader
import writer show Writer

DFPLAYER_STACK_HEADER ::= 0
DFPLAYER_STACK_VERSION ::= 1
DFPLAYER_STACK_LENGTH ::= 2
DFPLAYER_STACK_COMMAND ::= 3
DFPLAYER_STACK_ACK ::= 4
DFPLAYER_STACK_PARAMETER_HI ::= 5
DFPLAYER_STACK_PARAMETER_LO ::= 6
DFPLAYER_STACK_CHECKSUM_HI ::= 7
DFPLAYER_STACK_CHECKSUM_LO ::= 8
DFPLAYER_STACK_END ::= 9

// Command Actions
DFPLAYER_NEXT_SONG_ ::= 0x01
DFPLAYER_PREV_SONG_ ::= 0x02
DFPLAYER_PLAY_SONG_ ::= 0x03
DFPLAYER_VOLUME_UP_ ::= 0x04
DFPLAYER_VOLUME_DOWN_ ::= 0x05
DFPLAYER_VOLUME_SET_ ::= 0x06
DFPLAYER_EQUALIZER_SET_ := 0x07
DFPLAYER_PLAYBACK_SET_ := 0x08
DFPLAYER_PLAYBACK_SOURCESET_ := 0x09
DFPLAYER_STANDBY_ON_ := 0x0A
DFPLAYER_STANDBY_OFF_ := 0x0D
DFPLAYER_RESET_ := 0x0C
DFPLAYER_PAUSE_ := 0x0E
DFPLAYER_FOLDER_SET_ := 0x0F
DFPLAYER_VOLUME_ADJUST_SET_ := 0x10
DFPLAYER_REPEAT_SET_ := 0x11

// Query Actions
DFPLAYER_INIT_ ::= 0x3F
DFPLAYER_ERROR_ ::= 0x40
DFPLAYER_REPLY_ ::= 0x41
DFPLAYER_CURRENT_STATUS_GET_ ::= 0x42
DFPLAYER_CURRENT_VOLUME_GET_ ::= 0x43
DFPLAYER_CURRENT_EQ_GET_ ::= 0x44
DFPLAYER_CURRENT_PLAYBACK_GET_ ::= 0x45
DFPLAYER_CURRENT_VERSION_GET_ ::= 0x46
DFPLAYER_TF_FILES_COUNT_ ::= 0x47
DFPLAYER_U_FILES_COUNT_ ::= 0x48
DFPLAYER_FLASH_FILES_COUNT_ ::= 0x49
DFPLAYER_CURRENT_TF_TRACK_GET_ ::= 0x4B
DFPLAYER_CURRENT_U_TRACK_GET_ ::= 0x4C
DFPLAYER_CURRENT_FLASH_TRACK_GET_ ::= 0x4D


class DFPlayerMini:
    port_/Port
    writer_/Writer
    reader_/BufferedReader
    debug_/bool

    constructor --tx_pin/int --rx_pin/int --debug/bool=false:
        debug_ = debug

        if debug_:
            print "Opening port $tx_pin $rx_pin"

        port_ = Port
                --tx=gpio.Pin tx_pin
                --rx=gpio.Pin rx_pin
                --baud_rate=9600

        writer_ = Writer port_
        reader_ = BufferedReader port_

    next:
        send_command_ --action=DFPLAYER_NEXT_SONG_

    previous:
        send_command_ --action=DFPLAYER_PREV_SONG_

    play --song/int:
        send_command_ --action=DFPLAYER_PLAY_SONG_ --arg=song

    volume_up:
        send_command_ --action=DFPLAYER_VOLUME_UP_

    volume_down:
        send_command_ --action=DFPLAYER_VOLUME_DOWN_

    volume_set --volume/int:
        send_command_ --action=DFPLAYER_VOLUME_SET_ --arg=volume

    equalizer_set --equalizer/int:
        send_command_ --action=DFPLAYER_EQUALIZER_SET_ --arg=equalizer

    loop --loop/int:
        send_command_ --action=DFPLAYER_PLAYBACK_SET_ --arg=loop

    output_device --device/int:
        send_command_ --action=DFPLAYER_PLAYBACK_SOURCESET_ --arg=device
    
    sleep:
        send_command_ --action=DFPLAYER_STANDBY_ON_
    
    reset:
        send_command_ --action=DFPLAYER_RESET_
    
    start:
        send_command_ --action=DFPLAYER_STANDBY_OFF_

    pause:
        send_command_ --action=DFPLAYER_PAUSE_

    play_folder --folder/int --song/int=1:
        send_command_ --action=DFPLAYER_FOLDER_SET_ --arg=folder

    loop_all --enable/bool:
        arg := enable ? 1 : 0
        send_command_ --action=DFPLAYER_REPEAT_SET_ --arg=arg

    state_get -> int:
        response := send_command_ --action=DFPLAYER_CURRENT_STATUS_GET_
        return parse_response_ --response=response

    volume_get -> int:
        response := send_command_ --action=DFPLAYER_CURRENT_VOLUME_GET_
        return  parse_response_ --response=response

    eq_get -> int:
        response := send_command_ --action=DFPLAYER_CURRENT_EQ_GET_
        return parse_response_ --response=response

    playback_get -> int:
        response := send_command_ --action=DFPLAYER_CURRENT_PLAYBACK_GET_
        return parse_response_ --response=response
    
    version_get -> int:
        response := send_command_ --action=DFPLAYER_CURRENT_VERSION_GET_
        return parse_response_ --response=response

    tf_files_count -> int:
        response := send_command_ --action=DFPLAYER_TF_FILES_COUNT_
        return parse_response_ --response=response
    
    u_files_count -> int:
        response := send_command_ --action=DFPLAYER_U_FILES_COUNT_
        return parse_response_ --response=response

    flash_files_count -> int:
        response := send_command_ --action=DFPLAYER_FLASH_FILES_COUNT_
        return parse_response_ --response=response

    tf_track_get -> int:
        response := send_command_ --action=DFPLAYER_CURRENT_TF_TRACK_GET_
        return parse_response_ --response=response

    u_track_get -> int:
        response := send_command_ --action=DFPLAYER_CURRENT_U_TRACK_GET_
        return parse_response_ --response=response

    flash_track_get -> int:
        response := send_command_ --action=DFPLAYER_CURRENT_FLASH_TRACK_GET_
        return parse_response_ --response=response

    off:
        port_.close 

    send_command_ --action/int --arg/int?=null -> ByteArray?:
        base_command_ := #[0x7E, 0xFF, 06, 02, 01, 00, 00, 0xFE, 0xFA, 0xEF]
        command := base_command_
        command[DFPLAYER_STACK_COMMAND] = action

        if arg != null:
            command[DFPLAYER_STACK_PARAMETER_HI] = arg >> 8
            command[DFPLAYER_STACK_PARAMETER_LO] = arg

        if debug_:
            print "Sending command: $command"

        writer_.write (checksum_ command)

        reader_.clear
        response := reader_.read

        if response[DFPLAYER_STACK_COMMAND] == DFPLAYER_ERROR_:
            if debug_:
                print "Error: $response"

            return null

        return response

    parse_response_ --response/ByteArray:
        value := response[DFPLAYER_STACK_PARAMETER_HI] << 8
        value += response[DFPLAYER_STACK_PARAMETER_LO]
        return value

    checksum_ command/ByteArray -> ByteArray:
        checksum := 0
        command[1..7].do:
            checksum += it

        checksum = 0 - checksum

        command[DFPLAYER_STACK_CHECKSUM_HI] = checksum >> 8
        command[DFPLAYER_STACK_CHECKSUM_LO] = checksum

        return command