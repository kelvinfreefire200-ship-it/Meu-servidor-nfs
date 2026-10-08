#include <a_samp>

#define COR_AMARELO 0xFFFF00AA
#define COR_VERMELHO 0xFF0000AA
#define COR_VERDE 0x00FF00AA
#define COR_BRANCO 0xFFFFFFAA

#define MAX_APOSTAS 10
#define VALOR_MIN_APOSTA 1000

new CarroAdminEngly;
new EmCorrida[MAX_PLAYERS];
new ValorAposta[MAX_PLAYERS];
new TotalApostadores = 0;
new JogadoresApostando[MAX_APOSTAS];
new PremioTotal = 0;
new CorridaAtiva = 0;

new Float:SpawnLV[3] = {1685.0, 1450.0, 10.5};
new Float:PosCorridaInicio[3] = {2100.0, 1400.0, 10.5};
new Float:PosOficina[3] = {1640.0, 1200.0, 10.5};
new Float:PosFinal[3] = {2500.0, 1500.0, 10.5};

public OnGameModeInit()
{
    SetGameModeText("NFS Underground BR");
    ShowPlayerMarkers(1);
    ShowNameTags(1);
    SetWorldTime(20);

    CarroAdminEngly = CreateVehicle(562, 1685.0, 1450.0, 10.5, 0.0, 0, 0, 600);
    AddVehicleComponent(CarroAdminEngly, 1010);
    ChangeVehicleColor(CarroAdminEngly, 0, 0);

    CreateVehicle(411, 2100.0, 1400.0, 10.5, 0.0, -1, -1, 600);
    CreateVehicle(451, 2110.0, 1400.0, 10.5, 0.0, -1, -1, 600);
    CreateVehicle(541, 2120.0, 1400.0, 10.5, 0.0, -1, -1, 600);
    CreateVehicle(415, 2130.0, 1400.0, 10.5, 0.0, -1, -1, 600);
    CreateVehicle(429, 2140.0, 1400.0, 10.5, 0.0, -1, -1, 600);

    print("========================================");
    print("  SERVIDOR NFS UNDERGROUND BR INICIADO");
    print("  Spawn: Las Venturas");
    print("  Carro Admin: Engly (BMW M3 GTR)");
    print("========================================");
    return 1;
}

public OnGameModeExit()
{
    print("Servidor encerrado.");
    return 1;
}

public OnPlayerSpawn(playerid)
{
    SetPlayerPos(playerid, SpawnLV[0], SpawnLV[1], SpawnLV[2]);
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    SetCameraBehindPlayer(playerid);
    ResetPlayerWeapons(playerid);

    if(GetPlayerMoney(playerid) < 5000)
        GivePlayerMoney(playerid, 5000);

    SendClientMessage(playerid, COR_AMARELO, "========================================");
    SendClientMessage(playerid, COR_AMARELO, "  BEM-VINDO AO NFS UNDERGROUND BR!");
    SendClientMessage(playerid, COR_BRANCO, "  Use /apostar para apostar em corridas");
    SendClientMessage(playerid, COR_BRANCO, "  Use /tuning para personalizar seu carro");
    SendClientMessage(playerid, COR_BRANCO, "  Use /ajuda para ver todos os comandos");
    SendClientMessage(playerid, COR_AMARELO, "========================================");
    return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    if(newstate == PLAYER_STATE_DRIVER)
    {
        new vehicleid = GetPlayerVehicleID(playerid);
        if(vehicleid == CarroAdminEngly)
        {
            if(!IsPlayerAdmin(playerid))
            {
                RemovePlayerFromVehicle(playerid);
                SendClientMessage(playerid, COR_VERMELHO, "[ENGLY] Este veículo é exclusivo do Administrador!");
                return 0;
            }
            else
            {
                SendClientMessage(playerid, COR_VERDE, "[ENGLY] Você está dirigindo o carro mais rápido do servidor!");
                SetVehicleHealth(vehicleid, 5000.0);
            }
        }
    }
    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
    if(strcmp(cmdtext, "/apostar", true, 8) == 0)
    {
        if(EmCorrida[playerid])
        {
            SendClientMessage(playerid, COR_VERMELHO, "Você já está em uma corrida!");
            return 1;
        }

        new valor = strval(cmdtext[9]);
        if(valor < VALOR_MIN_APOSTA)
        {
            SendClientMessage(playerid, COR_AMARELO, "USE: /apostar [valor] (mínimo 1000)");
            return 1;
        }

        if(valor > GetPlayerMoney(playerid))
        {
            SendClientMessage(playerid, COR_VERMELHO, "Você não tem dinheiro suficiente!");
            return 1;
        }

        if(TotalApostadores >= MAX_APOSTAS)
        {
            SendClientMessage(playerid, COR_VERMELHO, "A corrida está cheia!");
            return 1;
        }

        ValorAposta[playerid] = valor;
        JogadoresApostando[TotalApostadores] = playerid;
        TotalApostadores++;
        PremioTotal += valor;
        GivePlayerMoney(playerid, -valor);
        EmCorrida[playerid] = 1;

        SetPlayerPos(playerid, PosCorridaInicio[0], PosCorridaInicio[1], PosCorridaInicio[2]);

        new msg[128];
        format(msg, sizeof(msg), "[APOSTA] %s apostou R$ %d! Prêmio total: R$ %d", GetPlayerName(playerid), valor, PremioTotal);
        SendClientMessageToAll(COR_AMARELO, msg);
        SendClientMessage(playerid, COR_VERDE, "Você está no ponto de largada! Pegue um carro e use /comecar.");
        return 1;
    }

    if(strcmp(cmdtext, "/comecar", true, 8) == 0)
    {
        if(!EmCorrida[playerid])
        {
            SendClientMessage(playerid, COR_VERMELHO, "Use /apostar antes de começar!");
            return 1;
        }
        if(TotalApostadores < 1)
        {
            SendClientMessage(playerid, COR_VERMELHO, "Ninguém apostou ainda!");
            return 1;
        }
        if(!IsPlayerInAnyVehicle(playerid))
        {
            SendClientMessage(playerid, COR_VERMELHO, "Você precisa estar em um veículo!");
            return 1;
        }
        new vehicleid = GetPlayerVehicleID(playerid);
        if(vehicleid == CarroAdminEngly && !IsPlayerAdmin(playerid))
        {
            SendClientMessage(playerid, COR_VERMELHO, "Você não pode usar o Engly para correr!");
            return 1;
        }

        CorridaAtiva = 1;
        SendClientMessageToAll(COR_VERDE, "========================================");
        SendClientMessageToAll(COR_AMARELO, "  CORRIDA INICIADA! VÁ ATÉ O CHECKPOINT!");
        new msg[128];
        format(msg, sizeof(msg), "  Prêmio total: R$ %d", PremioTotal);
        SendClientMessageToAll(COR_AMARELO, msg);
        SendClientMessageToAll(COR_VERDE, "========================================");

        for(new i = 0; i < TotalApostadores; i++)
        {
            SetPlayerCheckpoint(JogadoresApostando[i], PosFinal[0], PosFinal[1], PosFinal[2], 5.0);
        }
        return 1;
    }

    if(strcmp(cmdtext, "/tuning", true, 7) == 0)
    {
        if(!IsPlayerInAnyVehicle(playerid))
        {
            SendClientMessage(playerid, COR_VERMELHO, "Você precisa estar em um veículo!");
            return 1;
        }
        new vehicleid = GetPlayerVehicleID(playerid);
        if(vehicleid == CarroAdminEngly && !IsPlayerAdmin(playerid))
        {
            SendClientMessage(playerid, COR_VERMELHO, "Este carro é do admin!");
            return 1;
        }
        AddVehicleComponent(vehicleid, 1010);
        AddVehicleComponent(vehicleid, 1008);
        AddVehicleComponent(vehicleid, 1009);
        ChangeVehicleColor(vehicleid, random(100), random(100));
        SendClientMessage(playerid, COR_VERDE, "[TUNING] Nitro e hidráulico instalados!");
        return 1;
    }

    if(strcmp(cmdtext, "/oficina", true, 8) == 0)
    {
        SetPlayerPos(playerid, PosOficina[0], PosOficina[1], PosOficina[2]);
        SendClientMessage(playerid, COR_VERDE, "Você foi teleportado para a oficina!");
        return 1;
    }

    if(strcmp(cmdtext, "/ajuda", true, 6) == 0)
    {
        SendClientMessage(playerid, COR_AMARELO, "===== COMANDOS NFS UNDERGROUND =====");
        SendClientMessage(playerid, COR_BRANCO, "/apostar [valor] - Entra em uma corrida com aposta");
        SendClientMessage(playerid, COR_BRANCO, "/comecar - Inicia a corrida");
        SendClientMessage(playerid, COR_BRANCO, "/tuning - Personaliza seu carro");
        SendClientMessage(playerid, COR_BRANCO, "/oficina - Teleporta para a oficina");
        SendClientMessage(playerid, COR_BRANCO, "/adm - Comandos de admin");
        return 1;
    }

    if(strcmp(cmdtext, "/adm", true, 4) == 0)
    {
        if(!IsPlayerAdmin(playerid))
        {
            SendClientMessage(playerid, COR_VERMELHO, "Apenas admins!");
            return 1;
        }
        SendClientMessage(playerid, COR_AMARELO, "===== COMANDOS DE ADMIN =====");
        SendClientMessage(playerid, COR_BRANCO, "/rcon login [senha] - Login como admin");
        SendClientMessage(playerid, COR_BRANCO, "/engly - Teleporta até o carro Engly");
        return 1;
    }

    if(strcmp(cmdtext, "/engly", true, 6) == 0)
    {
        if(!IsPlayerAdmin(playerid))
        {
            SendClientMessage(playerid, COR_VERMELHO, "Apenas o Admin pode usar isso!");
            return 1;
        }
        SetPlayerPos(playerid, 1685.0, 1450.0, 10.5);
        SendClientMessage(playerid, COR_VERDE, "[ENGLY] Você foi teleportado para o carro exclusivo!");
        return 1;
    }

    return 0;
}

public OnPlayerEnterCheckpoint(playerid)
{
    if(CorridaAtiva && EmCorrida[playerid])
    {
        DisablePlayerCheckpoint(playerid);
        new msg[128];
        format(msg, sizeof(msg), "🏆 %s VENCEU A CORRIDA E LEVOU R$ %d!", GetPlayerName(playerid), PremioTotal);
        SendClientMessageToAll(COR_VERDE, msg);
        GivePlayerMoney(playerid, PremioTotal);

        for(new i = 0; i < TotalApostadores; i++)
        {
            new pID = JogadoresApostando[i];
            EmCorrida[pID] = 0;
            ValorAposta[pID] = 0;
            DisablePlayerCheckpoint(pID);
        }
        TotalApostadores = 0;
        PremioTotal = 0;
        CorridaAtiva = 0;

        for(new i = 0; i < MAX_PLAYERS; i++)
        {
            if(IsPlayerConnected(i))
            {
                SetPlayerPos(i, SpawnLV[0], SpawnLV[1], SpawnLV[2]);
            }
        }
    }
    return 1;
}

public OnPlayerConnect(playerid)
{
    new msg[128];
    format(msg, sizeof(msg), "%s entrou no servidor. Boa sorte nas corridas!", GetPlayerName(playerid));
    SendClientMessageToAll(COR_VERDE, msg);
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    if(EmCorrida[playerid])
    {
        EmCorrida[playerid] = 0;
        ValorAposta[playerid] = 0;
    }
    return 1;
}