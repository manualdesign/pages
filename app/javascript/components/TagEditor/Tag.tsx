import React from "react";

interface Props {
  enabled: boolean;
  tag: string;
  dispatch: (action: TagEditor.Action) => void;
}

export default function Tag(props: Props) {
  const handleChange = () => {
    props.dispatch({ type: "toggleTag", payload: props.tag });
  };

  const classes = ["tag"];
  if (props.enabled) {
    classes.push("enabled");
  }

  return (
    <span className={classes.join(" ")}>
      <label className="check-box">
        <input
          type="checkbox"
          name={"tag-" + props.tag}
          value="1"
          checked={props.enabled}
          onChange={handleChange}
        />
        <span className="name">{props.tag}</span>
      </label>
    </span>
  );
}
