const timed_filter = document.getElementById('timed');
const digital_filter = document.getElementById('digital-submission');
const search_input = document.getElementById('item-search')

function handleSection(section) {
  const value = search_input.value;
  const assignee_value = document.querySelector("input[type='radio'][name='assigned']:checked").value;
  const tables = [];
  const subsections = [];
  for (const t of section.children) {
    if (t.classList.contains('item-list')) {
      let anyVisibleRows = false;
      let rowCount = 0;
      for (const row of t.tBodies[0].getElementsByTagName('tr')) {
        let matches = false;
        if (value !== null) {
          matches = row.textContent.toLowerCase().includes(value.toLowerCase());
          if (assignee_value !== '') {
            if (assignee_value === 'false') {
              matches = matches && (!row.classList.contains('assigned') && !row.classList.contains('submitted'));
            } else {
              matches = matches && row.classList.contains(assignee_value);
            }
          }
        }
        if (timed_filter.checked) {
          matches = matches && row.classList.contains('timed');
        }
        if (digital_filter.checked) {
          matches = matches && row.classList.contains('digital-submission');
        }
        if (matches) {
          anyVisibleRows = true
          row.style.display = ''
        } else {
          row.style.display = 'none'
        }
        rowCount += 1;
      }
      if (!anyVisibleRows && rowCount !== 0) {
        t.style.display = 'none';
        tables.push(false);
      } else {
        tables.push(true);
        t.style.display = '';
      }
    } else if (t.tagName === 'SECTION') {
      subsections.push(handleSection(t, value));
    }
  }
  const anyVisible = subsections.concat(tables).some(e => e === true);
  if (!anyVisible) {
    section.style.display = 'none';
  } else {
    section.style.display = '';
  }
  return anyVisible
}

document.getElementById('item-search').addEventListener('input', e => {
  for (const section of document.querySelectorAll('#the-list > section')) {
    handleSection(section, e.target.value);
  }
})

function runSearch() {
  for (const section of document.querySelectorAll('#the-list > section')) {
    handleSection(section);
  }
}

for (const e of document.getElementsByName('assigned')) {
  e.addEventListener('change', runSearch);
}

[timed_filter, digital_filter].forEach(e => {
  e.addEventListener('change', runSearch);
})

runSearch();
