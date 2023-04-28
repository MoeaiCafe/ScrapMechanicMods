import { readFile, writeFile } from 'fs/promises';

const LIST = [
  'blocks.json',
  'building.json',
  'component.json',
  'consumable.json',
  'consumable_shared.json',
  'decor.json',
  'fittings.json',
  'industrial.json',
  'interactive.json',
  'interactivecontainers.json',
  'interactivecontainers_shared.json',
  'outfitpackage.json',
  'plantables.json',
  'spaceship.json',
  'vehicle.json',
  'warehouse.json',
]

const PREFIX = 'mod2/Survival/Objects/Database/ShapeSets/'

async function handleOne(filename) {
  filename = PREFIX + filename;

  const json = await readFile(filename, 'utf8');
  const obj = JSON.parse(json);
  const key = Object.keys(obj)[0];
  const value = obj[key];

  if (Array.isArray(value)) {
    value.forEach(v => {
      v.stackSize = 5000;
    });
  }

  const newJson = JSON.stringify(obj, null, '\t').replace(/\n/mg, '\r\n');
  await writeFile(filename, newJson, 'utf8');
}

async function main() {
  for (const filename of LIST) {
    console.log('--- handling: ', filename);
    await handleOne(filename);
  }
}
main();
