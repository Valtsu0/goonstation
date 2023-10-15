/**
 * @file
 * @copyright 2023
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { useBackend } from '../../backend';
import { LabeledList, Section } from '../../components';
import { CoordinateSlider } from './SteppedSlider';
import type { TeleConsoleData } from './types';
import { formatDecimal } from './util';

export const CoordinatesSection = (_props, context) => {
  const { act, data } = useBackend<TeleConsoleData>(context);
  const { xTarget, yTarget, zTarget } = data;
  return (
    <Section title="Target">
      <LabeledList>
        <LabeledList.Item label="X">
          <CoordinateSlider
            format={formatDecimal}
            maxValue={500}
            minValue={0}
            nudgeAmount={0.25}
            skipAmount={10}
            stepAmount={1}
            step={0.25}
            onChange={(value) => act('setX', { value })}
            value={xTarget}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Y">
          <CoordinateSlider
            format={formatDecimal}
            maxValue={500}
            minValue={0}
            nudgeAmount={0.25}
            skipAmount={10}
            stepAmount={1}
            step={0.25}
            onChange={(value) => act('setY', { value })}
            value={yTarget}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Z">
          <CoordinateSlider
            maxValue={14}
            minValue={0}
            onChange={(value) => act('setZ', { value })}
            stepPixelSize={16}
            value={zTarget}
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
