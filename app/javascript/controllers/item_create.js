import { FetchRequest } from '@rails/request.js';

const form = document.getElementsByClassName('item-form')[0];
const listCategoryInputName = "item[list_category_id]";
const pageNumberInput = document.getElementById("item_page_number");
pageNumberInput.addEventListener('input', listSectionChangeListener);
function itemTypeChangeListener() {
  const newValue = form.elements.namedItem(listCategoryInputName).value;
  pageNumberInput.required = newValue === "";
}
for (const e of document.getElementsByName(listCategoryInputName)) {
  e.addEventListener("change", itemTypeChangeListener)
  e.addEventListener("change", listSectionChangeListener)
}
itemTypeChangeListener();

const pointsValueInput = document.getElementById("item_points_value")
let pointsValueChanged = pointsValueInput.value !== '';
pointsValueInput.addEventListener("input", e => {
  pointsValueChanged = true;
});

document.getElementById("item_points_text").addEventListener("input", e => {
  if (pointsValueChanged) { return; }
  const pointsValueGuess = e.target.value.match(/\b(\d+)\b/);
  pointsValueInput.value = pointsValueGuess === null ? '' : pointsValueGuess[1];
});

let previewRefreshTimer = null;
const previewDelayMs = 700;
function listSectionChangeListener() {
  previewPane.replaceChildren([]);
  if (previewRefreshTimer !== null) {
    clearTimeout(previewRefreshTimer);
  }
  previewRefreshTimer = setTimeout(() => updatePreview(), previewDelayMs);
}

async function updatePreview() {
  const list_category_id = form.elements.namedItem('item[list_category_id]').value
  const page_number = form.elements.namedItem('item[page_number]').value
  const req = new FetchRequest('get', 'wizard', {query: {list_category_id, page_number}, responseKind: 'json'});
  const resp = await req.perform()
  const items = await resp.response.json();
  if (items.length === 0) return;
  createPreviewPane(items[0]);
  for (const item of items) {
    addItemToPane(item);
  }
  previewRefreshTimer = null;
}

function buildItemRow(item) {
  const e = document.createElement('tr');
  const num = document.createElement('td');
  num.textContent = item.page_number ? `${item.page_number}-${item.number}` : item.number;
  e.appendChild(num);
  const cts = document.createElement('td');
  if (item.points_text) {
    cts.textContent = `${item.content} [${item.points_text}]`;
  } else {
    cts.textContent = item.content;
  }
  cts.appendChild(document.createElement('br'));
  for (const tag of item.team_tags) {
    const t = document.createElement('span')
    t.classList.add('item-tag')
    t.style = `--tag-color: ${tag.color}`;
    t.textContent = tag.name
    cts.appendChild(t)
  }
  e.appendChild(cts);
  const editWrap = document.createElement('td');
  const edit = document.createElement('a');
  edit.href = item.path;
  edit.target = "_blank";
  edit.textContent = "✎"
  edit.classList.add('item-preview-edit');
  editWrap.appendChild(edit);
  e.appendChild(editWrap);
  return e;
}

function buildItemTable() {
  const t = document.createElement('table');
  t.classList.add('item-list');
  const thead = document.createElement('thead');
  const thead_row = document.createElement('tr');
  ['#', 'Item', ''].forEach(h => {
    const th = document.createElement('th');
    th.textContent = h;
    thead_row.appendChild(th);
  })
  thead.appendChild(thead_row);
  t.appendChild(thead);
  t.appendChild(document.createElement('tbody'));
  return t
}

const previewPane = document.getElementById('page-wrap');

const submitAndNextBtn = document.createElement('button');
submitAndNextBtn.textContent = "Next Item";
submitAndNextBtn.type = "button";
form.getElementsByClassName('item-submit-row')[0].appendChild(submitAndNextBtn);

let formLocked = false;
function lockFields() {
  form.elements.namedItem('item[list_category_id]').forEach(e => {
    e.disabled = !e.checked;
    e.defaultChecked = e.checked;
  });
  form.elements.namedItem('item[page_number]').setAttribute('readonly', '');
  form.elements.namedItem('item[page_number]').defaultValue = form.elements.namedItem('item[page_number]').value;
}

function createPreviewPane(item) {
  previewPane.appendChild(buildItemTable());
  if (item && item.finish_path) {
    const finishPageWrap = document.createElement('a');
    finishPageWrap.href = item.finish_path;
    const finishPageBtn = document.createElement('button');
    finishPageBtn.textContent = "Finish Page!"
    finishPageWrap.appendChild(finishPageBtn);
    previewPane.appendChild(finishPageWrap);
  }
}

function addItemToPane(item) {
  previewPane.getElementsByClassName('item-list')[0].tBodies[0].appendChild(buildItemRow(item));
}

submitAndNextBtn.addEventListener("click", async () => {
  if (!form.reportValidity()) { return; }
  const data = new FormData(form);
  // TODO: Need to report errors somehow
  const req = new FetchRequest('post', `${form.action}.json`, {body: data, responseKind: 'json'});
  const resp = await req.perform();
  const item = await resp.response.json();
  clearTimeout(previewRefreshTimer); // Prevent the running timer from overwriting the previewPane
  if (previewPane.childElementCount === 0) {
    createPreviewPane(item);
  }
  if (!formLocked) {
    lockFields();
    formLocked = true;
  }
  form.elements.namedItem('item[number]').valueAsNumber += 1;
  form.elements.namedItem('item[number]').defaultValue = form.elements.namedItem('item[number]').value;
  pointsValueChanged = false;
  form.reset();
  form.elements.namedItem('item[content]').focus();
  addItemToPane(item);
})
