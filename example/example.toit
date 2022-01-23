// Copyright (C) 2022 Fabrizio Arzeni.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the EXAMPLES_LICENSE file.

import dfplayermini show DFPlayerMini

main:
    player := DFPlayerMini
        --tx=17
        --rx=16

    player.play --song=1

    player.volume_set --volume=20
    
    sleep --ms=3000

    player.pause