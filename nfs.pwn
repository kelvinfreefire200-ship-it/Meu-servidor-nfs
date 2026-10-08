#include <a_samp>

#define COR_AMARELO 0xFFFF00AA
#define COR_VERMELHO 0xFF0000AA
#define COR_VERDE 0x00FF00AA
#define COR_BRANCO 0xFFFFFFAA

#define MAX_APOSTAS 10

new CarroAdminEngly;
new EmCorrida[MAX_PLAYERS];
new ValorAposta[MAX_PLAYERS];
new TotalApostadores = 0;
new JogadoresApostando[MAX_APOSTAS];
new PremioTotal = 0;

public OnGameModeInit()
{
    SetGameModeText("NFS Underground BR");
    SetWorldTime(20); // Clima de noite

    // Cria o carro do admin (Engly - BMW M3 GTR)
    CarroAdminEngly = CreateVehicle(562, 1685.0, 1450.0, 10.5, 0.0, 0, 0, 600);
    AddVehicleComponent(CarroAdminEngly, 1010); // Nitro
    ChangeVehicleColor(CarroAdminEngly, 0, 0);

    // Cria os carros de corrida em Las Venturas
    CreateVehicle(411, 2100.0, 1400.0, 10.5, 0.0, -1, -1, 600); // Infernus
    CreateVehicle(451, 2110.0, 1400.0, 10.5, 0.0, -1, -1, 600); // Turismo
    CreateVehicle(541, 2120.0, 1400.0, 10.5, 0.0, -1, -1, 600); // Bullet
    CreateVehicle(415, 2130.0, 1400.0, 10.5, 0.0, -1, -1, 600); // Cheetah
    CreateVehicle(429, 2140.0, 1400.0, 10.5, 0.0, -1, -1, 600); // Banshee

    print("========================================");
    print("  SERVIDOR NFS UNDERGROUND BR INICIADO");
    print("========================================");
    return 1;
}

public OnPlayerSpawn(playerid)
{
    SetPlayerPos(playerid, 1685.0, 1450.0, 10.5); // Spawn em Las Venturas
    SetCameraBehindPlayer(playerid);
    if(GetPlayerMoney(playerid) < 5000) GivePlayerMoney(playerid, 5000);

    SendClientMessage(playerid, COR_AMARELO, "========================================");
    SendClientMessage(playerid, COR_AMARELO, "  BEM-VINDO AO NFS UNDERGROUND BR!");
    SendClientMessage(playerid, COR_BRANCO, "  Use /ajuda para ver os comandos.");
    SendClientMessage(playerid, COR_AMARELO, "========================================");
    return 1;
}

// Proteção do carro do Admin
public OnPlayerStateChange(playerid, newstate, oldstate)
{
    if(newstate == PLAYER_STATE_DRIVER)
    {
        if(GetPlayerVehicleID(playerid) == CarroAdminEngly)
        {
            if(!IsPlayerAdmin(playerid))
            {
                RemovePlayerFromVehicle(playerid);
                SendClientMessage(playerid, COR_VERMELHO, "[ENGLY] Este veiculo e exclusivo do Administrador!");
            }
            else
            {
                SendClientMessage(playerid, COR_VERDE, "[ENGLY] Voce esta no carro mais rapido do servidor!");
                SetVehicleHealth(GetPlayerVehicleID(playerid), 5000.0);
            }
        }
    }
    return 1;
}

// Comandos
public OnPlayerCommandText(playerid, cmdtext[])
{
    if(strcmp(cmdtext, "/ajuda", true) == 0)
    {
        SendClientMessage(playerid, COR_AMARELO, "===== COMANDOS =====");
        SendClientMessage(playerid, COR_BRANCO, "/apostar [valor] - Entra em uma corrida com aposta");
        SendClientMessage(playerid, COR_BRANCO, "/comecar - Inicia a corrida");
        SendClientMessage(playerid, COR_BRANCO, "/tuning - Personaliza seu carro");
        SendClientMessage(playerid, COR_BRANCO, "/engly - Teleporta para o carro do Admin");
        return 1;
    }

    if(strcmp(cmdtext, "/apostar", true, 8) == 0)
    {
        if(!IsPlayerInAnyVehicle(playerid))
        {
            SendClientMessage(playerid, COR_VERMELHO, "Voce precisa estar em um veiculo para apostar!");
            return 1;
        }
        new valor = strval(cmdtext[9]);
        if(valor < 1000)
        {
            SendClientMessage(playerid, COR_VERMELHO, "A aposta minima e R$ 1000. Ex: /apostar 5000");
            return 1;
        }
        if(valor > GetPlayerMoney(playerid))
        {
            SendClientMessage(playerid, COR_VERMELHO, "Voce nao tem dinheiro suficiente!");
            return 1;
        }
        GivePlayerMoney(playerid, -valor);
        PremioTotal += valor;
        EmCorrida[playerid] = 1;
        
        SetPlayerCheckpoint(playerid, 2500.0, 1500.0, 10.5, 5.0);
        SendClientMessage(playerid, COR_VERDE, "Corrida iniciada! Va ate o checkpoint!");
        return 1;
    }

    if(strcmp(cmdtext, "/tuning", true) == 0)
    {
        if(!IsPlayerInAnyVehicle(playerid))
        {
            SendClientMessage(playerid, COR_VERMELHO, "Voce precisa estar em um veiculo!");
            return 1;
        }
        new v = GetPlayerVehicleID(playerid);
        if(v == CarroAdminEngly && !IsPlayerAdmin(playerid))
        {
            SendClientMessage(playerid, COR_VERMELHO, "Este carro e do Admin!");
            return 1;
        }
        AddVehicleComponent(v, 1010); // Nitro
        AddVehicleComponent(v, 1008); // Nitro 2x
        AddVehicleComponent(v, 1009); // Hidraulico
        ChangeVehicleColor(v, random(100), random(100));
        SendClientMessage(playerid, COR_VERDE, "[TUNING] Nitro e hidraulico instalados!");
        return 1;
    }

    if(strcmp(cmdtext, "/engly", true) == 0)
    {
        if(!IsPlayerAdmin(playerid)) 
        {
            SendClientMessage(playerid, COR_VERMELHO, "Apenas o Admin pode usar isso!");
            return 1;
        }
        SetPlayerPos(playerid, 1685.0, 1450.0, 10.5);
        SendClientMessage(playerid, COR_VERDE, "[ENGLY] Voce foi teleportado para o carro exclusivo!");
        return 1;
    }

    return 0;
}

// Final da corrida
public OnPlayerEnterCheckpoint(playerid)
{
    if(EmCorrida[playerid])
    {
        DisablePlayerCheckpoint(playerid);
        GivePlayerMoney(playerid, PremioTotal);
        
        new msg[128];
        format(msg, sizeof(msg), "%s venceu a corrida e levou R$ %d!", GetPlayerName(playerid), PremioTotal);
        SendClientMessageToAll(COR_VERDE, msg);
        
        EmCorrida[playerid] = 0;
        PremioTotal = 0;
        SetPlayerPos(playerid, 1685.0, 1450.0, 10.5);
    }
    return 1;
}
