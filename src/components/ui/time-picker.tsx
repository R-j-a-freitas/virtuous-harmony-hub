import React from "react";
import { Input } from "./input";
import { Label } from "./label";

interface TimePickerProps {
  value: string; // Expected format: "HH:MM"
  onChange: (value: string) => void;
  label?: string;
  required?: boolean;
  className?: string;
  placeholder?: string;
}

const TimePicker: React.FC<TimePickerProps> = ({
  value,
  onChange,
  label,
  required = false,
  className = "",
  placeholder = "HH:MM"
}) => {
  const [hours, minutes] = value.split(':').map(Number);

  const handleHoursChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const newHours = parseInt(e.target.value, 10);
    if (isNaN(newHours) || newHours < 0 || newHours > 23) {
      onChange(''); // Clear if invalid
      return;
    }
    const formattedHours = String(newHours).padStart(2, '0');
    const currentMinutes = String(minutes || 0).padStart(2, '0');
    onChange(`${formattedHours}:${currentMinutes}`);
  };

  const handleMinutesChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const newMinutes = parseInt(e.target.value, 10);
    if (isNaN(newMinutes) || newMinutes < 0 || newMinutes > 59) {
      onChange(''); // Clear if invalid
      return;
    }
    const formattedMinutes = String(newMinutes).padStart(2, '0');
    const currentHours = String(hours || 0).padStart(2, '0');
    onChange(`${currentHours}:${formattedMinutes}`);
  };

  return (
    <div className={`space-y-2 ${className}`}>
      {label && (
        <Label htmlFor="time-picker-hours" className="text-sm font-medium">
          {label} {required && <span className="text-red-500">*</span>}
        </Label>
      )}
      <div className="flex items-center space-x-2">
        <Input
          id="time-picker-hours"
          type="number"
          min="0"
          max="23"
          value={isNaN(hours) ? '' : hours}
          onChange={handleHoursChange}
          placeholder="HH"
          required={required}
          className="w-16 text-center"
        />
        <span className="text-foreground">:</span>
        <Input
          id="time-picker-minutes"
          type="number"
          min="0"
          max="59"
          value={isNaN(minutes) ? '' : minutes}
          onChange={handleMinutesChange}
          placeholder="MM"
          required={required}
          className="w-16 text-center"
        />
      </div>
    </div>
  );
};

export default TimePicker;
