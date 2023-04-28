import { readFile, writeFile } from 'fs/promises';

const LIST = [
  'mod2/Data/Objects/Database/ShapeSets/blocks.json',
  'mod2/Data/Objects/Database/ShapeSets/decor.json',
  'mod2/Data/Objects/Database/ShapeSets/fittings.json',
  'mod2/Data/Objects/Database/ShapeSets/industrial.json',
  'mod2/Data/Objects/Database/ShapeSets/interactive.json',
  'mod2/Data/Objects/Database/ShapeSets/spaceship.json',
  'mod2/Data/Objects/Database/ShapeSets/vehicle.json',

  'mod2/Survival/Objects/Database/ShapeSets/blocks.json',
  'mod2/Survival/Objects/Database/ShapeSets/building.json',
  'mod2/Survival/Objects/Database/ShapeSets/component.json',
  'mod2/Survival/Objects/Database/ShapeSets/consumable.json',
  'mod2/Survival/Objects/Database/ShapeSets/consumable_shared.json',
  'mod2/Survival/Objects/Database/ShapeSets/decor.json',
  'mod2/Survival/Objects/Database/ShapeSets/fittings.json',
  'mod2/Survival/Objects/Database/ShapeSets/industrial.json',
  'mod2/Survival/Objects/Database/ShapeSets/interactive.json',
  'mod2/Survival/Objects/Database/ShapeSets/interactivecontainers.json',
  'mod2/Survival/Objects/Database/ShapeSets/interactivecontainers_shared.json',
  'mod2/Survival/Objects/Database/ShapeSets/outfitpackage.json',
  'mod2/Survival/Objects/Database/ShapeSets/plantables.json',
  'mod2/Survival/Objects/Database/ShapeSets/resources.json',
  'mod2/Survival/Objects/Database/ShapeSets/spaceship.json',
  'mod2/Survival/Objects/Database/ShapeSets/vehicle.json',
  'mod2/Survival/Objects/Database/ShapeSets/warehouse.json',
]

async function handleOne(filename) {
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
