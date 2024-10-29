function closeShop() {
    fetch(`https://${GetParentResourceName()}/closeShop`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    });
    document.getElementById('shop-menu').classList.add('hidden');
}

function buyCard() {
    fetch(`https://${GetParentResourceName()}/buyCard`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    });
}

function sellCard() {
    fetch(`https://${GetParentResourceName()}/sellCard`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    });
}

window.addEventListener('message', function(event) {
    if (event.data.action === "openShop") {
        document.getElementById('shop-menu').classList.remove('hidden');
    }
});