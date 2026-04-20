function handleSection(section, value) {
  const tables = [];
  const subsections = [];
  for (const t of section.children) {
    if (t.classList.contains('item-list')) {
      let anyVisibleRows = false;
      let rowCount = 0;
      for (const row of t.tBodies[0].getElementsByTagName('tr')) {
        if (value === null || row.textContent.toLowerCase().includes(value.toLowerCase())) {
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

/* TODO: Add list category pages (so that the item create wizard can link to them) */

document.getElementById('item-search').addEventListener('input', e => {
  console.log("inpoo")
  for (const section of document.querySelectorAll('#the-list > section')) {
    handleSection(section, e.target.value);
  }
})
