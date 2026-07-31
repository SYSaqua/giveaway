const uiState = document.querySelector(".form")
const prize = document.querySelector("#prize_box .prize_text")
const currEntries = document.querySelector("#entries span:first-child")
const maxEntries = document.querySelector("#entries span:last-child")
const timer = document.querySelector("#timer p")

const ToggleUI = (state) => {
    if (state) {
        uiState.style.display = "flex";
    } else {
        uiState.style.display = "none";
    }
}

const UpdateData = (data) => {
    prize.textContent = data.amount + "x " + data.label;
    UpdateEntries(0, data.entries);
    UpdateTimer(data.duration);
}

const UpdateEntries = (current, total) => {
    currEntries.textContent = Number(current);
    maxEntries.textContent = "/" + Number(total);
}

const UpdateTimer = (time) => {
    timer.textContent = time;
}

const Init = (event) => {
    const { action, data } = event.data;

    switch (action) {
        case "ToggleUI":
            ToggleUI(data.state);
            break;
        case "UpdateData":
            UpdateData(data);
            break;
        case "UpdateEntries":
            currEntries.textContent = Number(data.count);
            break;
        case "UpdateTimer":
            UpdateTimer(data.time);
            break;
    }
}

window.addEventListener("message", Init);