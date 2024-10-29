let isScratching = false;
let canvas, ctx;
let prizeRevealed = false;
let lastScratchTime = 0;
let scratchPattern;
let coinRotation = 0;
let serverWinAmount = 0;
let cardSerial = '';

window.addEventListener('message', function(event) {
    if (event.data.action === "openScratchCard") {
        document.getElementById('scratch-card').classList.remove('hidden');
        document.getElementById('win-overlay').classList.add('hidden');
        serverWinAmount = event.data.winAmount;
        cardSerial = event.data.serial;
        document.getElementById('serial').textContent = cardSerial;
        initializeScratchCard();
    }
});

async function initializeScratchCard() {
    canvas = document.getElementById('scratch-canvas');
    ctx = canvas.getContext('2d');
    
    // Aseta canvas koko
    canvas.width = 600;
    canvas.height = 400;
    
    scratchPattern = await createScratchPattern();
    ctx.fillStyle = scratchPattern;
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    addMetallicEffect();
    generatePrizes();
    
    canvas.addEventListener('mousedown', startScratching);
    canvas.addEventListener('mousemove', scratch);
    canvas.addEventListener('mouseup', stopScratching);
    canvas.addEventListener('mouseleave', stopScratching);
    
    prizeRevealed = false;
}

async function createScratchPattern() {
    const pattern = document.createElement('canvas');
    pattern.width = 100;
    pattern.height = 100;
    const patternCtx = pattern.getContext('2d');
    
    // Luo metallinhohtava pinta
    const gradient = patternCtx.createLinearGradient(0, 0, 100, 100);
    gradient.addColorStop(0, '#C0C0C0');
    gradient.addColorStop(0.5, '#E8E8E8');
    gradient.addColorStop(1, '#B8B8B8');
    
    patternCtx.fillStyle = gradient;
    patternCtx.fillRect(0, 0, 100, 100);
    
    // Lisää tekstuuri
    for (let i = 0; i < 50; i++) {
        patternCtx.fillStyle = `rgba(255,255,255,${Math.random() * 0.1})`;
        patternCtx.beginPath();
        patternCtx.arc(
            Math.random() * 100,
            Math.random() * 100,
            Math.random() * 3,
            0,
            Math.PI * 2
        );
        patternCtx.fill();
    }
    
    return ctx.createPattern(pattern, 'repeat');
}

function addMetallicEffect() {
    const gradient = ctx.createLinearGradient(0, 0, canvas.width, canvas.height);
    gradient.addColorStop(0, 'rgba(255,255,255,0.2)');
    gradient.addColorStop(0.5, 'rgba(255,255,255,0)');
    gradient.addColorStop(1, 'rgba(255,255,255,0.2)');
    
    ctx.fillStyle = gradient;
    ctx.fillRect(0, 0, canvas.width, canvas.height);
}

function startScratching(e) {
    isScratching = true;
    scratch(e);
}

function scratch(e) {
    if (!isScratching) return;
    
    const rect = canvas.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    
    ctx.globalCompositeOperation = 'destination-out';
    ctx.beginPath();
    ctx.arc(x, y, 25, 0, Math.PI * 2);
    ctx.fill();
    
    checkRevealProgress();
}

function stopScratching() {
    isScratching = false;
}

function generatePrizes() {
    const prizeArea = document.getElementById('prize-area');
    prizeArea.innerHTML = '';
    
    // Käytä palvelimelta saatua voittosummaa
    const winningAmount = serverWinAmount;
    
    // Luo 9 ruutua, joista 3 sisältää voittosumman
    const prizes = Array(9).fill(0);
    const winningPositions = [];
    
    // Valitse 3 satunnaista positiota voittosummalle
    while (winningPositions.length < 3) {
        const pos = Math.floor(Math.random() * 9);
        if (!winningPositions.includes(pos)) {
            winningPositions.push(pos);
            prizes[pos] = winningAmount;
        }
    }
    
    // Täytä loput ruudut satunnaisilla summilla
    const possiblePrizes = [3, 10, 30, 1000, 100000];
    for (let i = 0; i < 9; i++) {
        if (!winningPositions.includes(i)) {
            let randomPrize;
            do {
                randomPrize = possiblePrizes[Math.floor(Math.random() * possiblePrizes.length)];
            } while (randomPrize === winningAmount);
            prizes[i] = randomPrize;
        }
        
        const prizeDiv = document.createElement('div');
        prizeDiv.className = 'prize-item';
        prizeDiv.textContent = prizes[i] + '€';
        prizeArea.appendChild(prizeDiv);
    }
}

function checkRevealProgress() {
    if (prizeRevealed) return;
    
    const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);
    const pixels = imageData.data;
    let transparent = 0;
    
    for (let i = 0; i < pixels.length; i += 4) {
        if (pixels[i + 3] < 128) transparent++;
    }
    
    const percentRevealed = transparent / (pixels.length / 4);
    if (percentRevealed > 0.5) {
        revealPrize();
    }
}

function revealPrize() {
    prizeRevealed = true;
    
    // Näytä voittoilmoitus
    document.getElementById('win-amount').textContent = serverWinAmount;
    document.getElementById('win-overlay').classList.remove('hidden');
    
    // Lähetä voitto palvelimelle
    fetch(`https://${GetParentResourceName()}/claimPrize`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            winAmount: serverWinAmount,
            serial: cardSerial
        })
    });
}

document.getElementById('close-btn').addEventListener('click', function() {
    document.getElementById('scratch-card').classList.add('hidden');
    fetch(`https://${GetParentResourceName()}/closeScratchCard`, {
        method: 'POST'
    });
});