package.path = reaper.GetResourcePath() .. '/Scripts/rtk/1/?.lua'
local rtk = require('rtk')
local log = rtk.log
log.level = log.DEBUG

-- create consts for note lengths
local SIXTEENTH = 16
local EIGHTH = 8
local QUARTER = 4
local HALF = 2
local WHOLE = 1

local A4 = 69

function info(x)
    y = tostring(x)
    log.debug(y)
    log.flush()
end

function calculate_note_length(note_denominator)
    local tempo, _ = reaper.GetProjectTimeSignature2()
    local note_length = (60 / tempo) / (note_denominator / 4) -- assuming 4/4 time
    return note_length
end

function zoom_to_note_length(note_length)
    local start_time = reaper.GetCursorPosition()
    end_time = start_time + note_length

    local track_index = reaper.GetNumTracks()
    reaper.InsertTrackAtIndex(track_index, false)
    local track = reaper.GetTrack(0, track_index)
    local item = reaper.CreateNewMIDIItemInProj(track, start_time, end_time, false)

    reaper.SetMediaItemSelected(item, true)
    reaper.Main_OnCommand(40913, 0) -- Zoom to selected items
end

function add_track()
    local track_index = reaper.GetNumTracks()
    reaper.InsertTrackAtIndex(track_index, false)
    local track = reaper.GetTrack(0, track_index)
    return track
end

function add_midi_item(track, start, length)
    endtime = start + length
    midi = reaper.CreateNewMIDIItemInProj(track, start, endtime)
    return midi
end

function get_first_take(item)
    return reaper.GetTake(item, 0)
end

function new_midi_take(track, start, length)
    item = add_midi_item(track, start, length)
    take = get_first_take(item, 0)
    return take
end

function get_take_length_ppq(take)
    ppqn = reaper.BR_GetMidiSourceLenPPQ(take)
    return ppqn
end

function add_note(item, startposppq, endposppq, pitch, vel)
    take = get_first_take(item)
    info("take")
    info(reaper.ValidatePtr(take, "MediaItem_Take*"))
    reaper.MIDI_InsertNote(take, false, false, startposppq, endposppq, 1, pitch, vel, true)
end

function calculate_note_length_ppq(note_denominator)
    qnote_length_sec = calculate_note_length(QUARTER)
    temp_track = add_track()
    temp_midi_item = add_midi_item(temp_track, 0, qnote_length_sec)
    temp_midi_take = get_first_take(temp_midi_item)
    qnote_length_ppq = get_take_length_ppq(temp_midi_take)
    reaper.DeleteTrack(temp_track)
    return qnote_length_ppq
end

function insert_pulse_track(length)
    local track = add_track()
    local start = 0
    local item = add_midi_item(track, start, length)

    -- insert a note every quarter note
    local qnote_length_sec = calculate_note_length(QUARTER)
    local max_qnotes = length / qnote_length_sec
    local qnote_length_ppq = calculate_note_length_ppq(QUARTER)
    for i = 1, max_qnotes do
        local note_start = qnote_length_ppq * (i - 1)
        local note_stop = (qnote_length_ppq * i) - (qnote_length_ppq // 20)
        add_note(item, note_start, note_stop, A4, 127)
    end
end

function main()
    insert_pulse_track(120)
end

main()
